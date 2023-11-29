#!/bin/sh

############################################
##       Path to dependencies           ####
############################################

dirasp=/data/icesat/travail_sauve/Etienne/ASP/StereoPipeline-3.0.0-2021-10-05-x86_64-Linux
dirotb=/data/icesat/travail_sauve/Etienne/OTB/OTB-7.2.0-Linux64
export PATH=$dirasp/bin:$dirotb/bin:$HOME/bin:$PATH

############################################
##             Parameters               ####
############################################

Rough_DEM_full=/data/icesat/produits/Global_DEM/GLO-30m-DTED/GLO-30_Glaciers.vrt  # link to a reference DEM for mapproject
dir=/data/icesat/travail_en_cours/jerome/PGO/GitHub/2022-08-16_1104094_Langfjordjokelen_SCA/ # Directory with PAN and MS folder images
COR=BM # Choose Block Matching (BM) or Semi Global Matching (SGM)
name=Langfjordjokelen_SCA # Output prefix for DEM and ortho-images

#########################################
##             Process               ####
#########################################


echo " "
echo "##########################################################################"
echo " PHR DEM extraction using ASP, and a seed DEM"
echo " Create map-projected PAN and MS images"
echo "##########################################################################"
echo " "

dirname=`dirname "$0"`
. ${dirname}/functions/aditional_function.sh

diro=${dir}/${COR}
mkdir $diro
dirout=${dir}/${COR}/tmp
mkdir $dirout

SENSOR=`ls ${dir} | grep "P_001" | awk -F"_" '{print $2}'`
EXT=`ls ${dir}/IMG_${SENSOR}_P_001 | grep "IMG" | head -2 | tail -1 | awk -F"." '{print $2}'`
nb_threads=8

echo " "
echo "##########################################################################"
echo " DEM calculation"
echo "##########################################################################"
echo " "

dir1=$dir/IMG_${SENSOR}_P_001
img1=$dir1/img1.vrt
rpc1=$dir1/RPC*

dir1MS=$dir/IMG_${SENSOR}_MS_003
img1MS=$dir1MS/img1MS.vrt
rpc1MS=$dir1MS/RPC*

dir2=$dir/IMG_${SENSOR}_P_002
img2=$dir2/img2.vrt
rpc2=$dir2/RPC*

dir2MS=$dir/IMG_${SENSOR}_MS_004
img2MS=$dir2MS/img2MS.vrt
rpc2MS=$dir2MS/RPC*

#############################################################################
# Extract longitude/latitude of the center of the image & define the UTM zone + value of the NS variable
#############################################################################

lon=`more $dir1/DIM_* | grep "<LON>" | tail -1 | awk -F">" '{print $2}'| awk -F"<" '{print $1}'`
lat=`more $dir1/DIM_* | grep "<LAT>" | tail -1 | awk -F">" '{print $2}'| awk -F"<" '{print $1}'`
utm=`echo "($lon + 180)/6.+1" | bc`

if [ $(echo "$lat > 0" | bc -l) -eq 1 ]; then
    echo "NORTH"
    H=north
    NS=+north
    azimuth=337.5 # from http://dx.doi.org/10.1080/15230406.2016.1185647
fi

if [ $(echo "$lat < 0" | bc -l) -eq 1 ]; then
    echo "SOUTH"
    H=south
    NS=+south
    azimuth=337.5 # from http://dx.doi.org/10.1080/15230406.2016.1185647
fi

#############################################################################
# Extract longitude max/min and latitude max/min to calculate bounding box of the image 
#############################################################################

filename=`ls ${dir}/IMG_${SENSOR}_P_001/DIM_*`
boundingbox=$(get_extend $filename)

outpath_bb=$dir/${name}_GLO30.tif
outpath_bb_utm=$dir/${name}_GLO30_UTM.tif

gdalwarp -t_srs '+proj=longlat +datum=WGS84 +no_defs' -tr 0.00027 0.00027 -te $boundingbox -r cubic $Rough_DEM_full  $outpath_bb
gdalwarp -t_srs "+proj=utm +zone=$utm $NS +units=m +datum=WGS84" -tr 30 30 -r cubic $outpath_bb $outpath_bb_utm

#############################################################################
# Choose the resolution of the different DEMs
#############################################################################

if [ "$SENSOR" = PHR1B ]; then
DEM_PS1=2
DEM_PS2=20
ORTHO_PS=0.5
ORTHO_MS_PS=2
fi

if [ "$SENSOR" = PHR1A ]; then
DEM_PS1=2
DEM_PS2=20
ORTHO_PS=0.5
ORTHO_MS_PS=2
fi

#############################################################################
# Merge the different tiles in .vrt files
#############################################################################
if [ ! -e  $img1 ] ; then
	gdalbuildvrt $img1 $dir1/*.${EXT}
fi

if [ ! -e  $img1MS ] ; then
	gdalbuildvrt $img1MS $dir1MS/*.${EXT}
fi

if [ ! -e  $img2 ] ; then
	gdalbuildvrt $img2 $dir2/*.${EXT}
fi

if [ ! -e  $img2MS ] ; then
	gdalbuildvrt $img2MS $dir2MS/*.${EXT}
fi

#############################################################################
# Extract the MS individual bands
#############################################################################

img1red=$dirout/img1_red.tif
img1gre=$dirout/img1_gre.tif
img1blu=$dirout/img1_blu.tif
img1nir=$dirout/img1_nir.tif
if [ ! -e $img1red ] ; then
        gdal_translate -b 1 $img1MS $dirout/img1_red.tif
        gdal_translate -b 2 $img1MS $dirout/img1_gre.tif
        gdal_translate -b 3 $img1MS $dirout/img1_blu.tif
        gdal_translate -b 4 $img1MS $dirout/img1_nir.tif
fi

img2red=$dirout/img2_red.tif
img2gre=$dirout/img2_gre.tif
img2blu=$dirout/img2_blu.tif
img2nir=$dirout/img2_nir.tif
if [ ! -e $img2red ] ; then
	gdal_translate -b 1  $img2MS $img2red
        gdal_translate -b 2  $img2MS $img2gre
        gdal_translate -b 3  $img2MS $img2blu
        gdal_translate -b 4  $img2MS $img2nir
fi

#############################################################################
# Choose here to perform the bundle adjustment or not			   
#############################################################################

mkdir ${dirout}/ba_run_NO
BA_prefix=${dirout}/ba_run_NO/out

rpc1_txt=`ls $rpc1 | awk -F"/" '{print $NF}' | awk -F"." '{print $1}'`
echo "0 0 0" > $dirout/ba_run_NO/out-${rpc1_txt}.adjust
echo "1 0 0 0" >> $dirout/ba_run_NO/out-${rpc1_txt}.adjust
rpc1MS_txt=`ls $rpc1MS | awk -F"/" '{print $NF}' | awk -F"." '{print $1}'`
echo "0 0 0" > $dirout/ba_run_NO/out-${rpc1MS_txt}.adjust
echo "1 0 0 0" >> $dirout/ba_run_NO/out-${rpc1MS_txt}.adjust
rpc2_txt=`ls $rpc2 | awk -F"/" '{print $NF}' | awk -F"." '{print $1}'`
echo "0 0 0" > $dirout/ba_run_NO/out-${rpc2_txt}.adjust
echo "1 0 0 0" >> $dirout/ba_run_NO/out-${rpc2_txt}.adjust
rpc2MS_txt=`ls $rpc2MS | awk -F"/" '{print $NF}' | awk -F"." '{print $1}'`
echo "0 0 0" > $dirout/ba_run_NO/out-${rpc2MS_txt}.adjust
echo "1 0 0 0" >> $dirout/ba_run_NO/out-${rpc2MS_txt}.adjust

##################################################################################
# Generation of the DEM at different resolution including a point2dem ortho-image
##################################################################################

mapproject --ot UInt16 --nodata-value 0 -t rpc --t_srs "+proj=utm +zone=$utm $NS +units=m +datum=WGS84" --threads ${nb_threads} --mpp ${ORTHO_PS} $outpath_bb $img1 $rpc1 $dirout/img1_mapproj.tif --bundle-adjust-prefix $BA_prefix
mapproject --ot UInt16 --nodata-value 0 -t rpc --t_srs "+proj=utm +zone=$utm $NS +units=m +datum=WGS84" --threads ${nb_threads} --mpp ${ORTHO_PS} $outpath_bb $img2 $rpc2 $dirout/img2_mapproj.tif --bundle-adjust-prefix $BA_prefix

if [ "$COR" = SGM ]; then
echo "DEM computed using the $SGM (Semi Global Matching) algorithm"
settings=${dirname}/functions/stereo.default_SGM

###Use if you perform the process on a cluster ###
#parallel_stereo --processes 7 --nodes-list $PBS_NODEFILE --threads-singleprocess 8 --parallel-options "--sshdelay 1 --controlmaster" -t rpcmaprpc -s $settings \
#                $dirout/img1_mapproj.tif $dirout/img2_mapproj.tif $rpc1 $rpc2 $dirout/$name ${outpath_bb}

parallel_stereo --processes 4 --threads-singleprocess 4 -t rpcmaprpc -s $settings \
                $dirout/img1_mapproj.tif $dirout/img2_mapproj.tif $rpc1 $rpc2 $dirout/$name ${outpath_bb}                            
fi


if [ "$COR" = BM ]; then
echo "DEM computed using the $COR Block Matching algorithm"
settings=${dirname}/functions/stereo.default.Int
stereo -t rpcmaprpc -s $settings --alignment-method none \
		$dirout/img1_mapproj.tif $dirout/img2_mapproj.tif $rpc1 $rpc2 $dirout/$name ${outpath_bb}
fi

DEM_PS=$DEM_PS1
point2dem -r earth --t_srs "+proj=utm +zone=$utm $NS +units=m +datum=WGS84" --threads ${nb_threads} --tr ${DEM_PS} --nodata-value -9999 $dirout/$name-PC.tif -t ${DEM_PS}m.tif
gdal_translate -a_nodata -9999 -ot float32 $dirout/$name-DEM.${DEM_PS}m.tif $dirout/${name}_DEM_${DEM_PS}m.tif
mv $dirout/${name}_DEM_${DEM_PS}m.tif ${dir}/${COR}/${name}_DEM_${COR}_${DEM_PS}m.tif

DEM_PS=$DEM_PS2
point2dem -r earth --t_srs "+proj=utm +zone=$utm $NS +units=m +datum=WGS84" --threads ${nb_threads} --tr ${DEM_PS} --nodata-value -9999 $dirout/$name-PC.tif -t ${DEM_PS}m.tif
gdal_translate -a_nodata -9999 -ot float32 $dirout/$name-DEM.${DEM_PS}m.tif $dirout/${name}_DEM_${DEM_PS}m.tif
mv $dirout/${name}_DEM_${DEM_PS}m.tif ${dir}/${COR}/${name}_DEM_${COR}_${DEM_PS}m.tif

#Manage nodata
gdal_calc.py -A ${dir}/${COR}/${name}_DEM_${COR}_${DEM_PS1}m.tif --outfile=${dir}/${COR}/${name}_DEM_${COR}_${DEM_PS1}m_no.tif --calc="numpy.where(A>=3e38, -9999, A)"
gdal_calc.py -A ${dir}/${COR}/${name}_DEM_${COR}_${DEM_PS2}m.tif --outfile=${dir}/${COR}/${name}_DEM_${COR}_${DEM_PS2}m_no.tif --calc="numpy.where(A>=3e38, -9999, A)"

mv ${dir}/${COR}/${name}_DEM_${COR}_${DEM_PS1}m.tif  ${dir}/${COR}/tmp/${name}_DEM_${COR}_${DEM_PS1}m.tif
mv ${dir}/${COR}/${name}_DEM_${COR}_${DEM_PS2}m.tif  ${dir}/${COR}/tmp/${name}_DEM_${COR}_${DEM_PS2}m.tif

gdal_translate -a_nodata -9999 ${dir}/${COR}/${name}_DEM_${COR}_${DEM_PS1}m_no.tif ${dir}/${COR}/${name}_DEM_${COR}_${DEM_PS1}m.tif
gdal_translate -a_nodata -9999 ${dir}/${COR}/${name}_DEM_${COR}_${DEM_PS2}m_no.tif ${dir}/${COR}/${name}_DEM_${COR}_${DEM_PS2}m.tif

rm ${dir}/${COR}/${name}_DEM_${COR}_${DEM_PS1}m_no.tif
rm ${dir}/${COR}/${name}_DEM_${COR}_${DEM_PS2}m_no.tif


FULL_DEM=${dir}/${COR}/${name}_DEM_${COR}_${DEM_PS2}m.tif


echo " "
echo "##########################################################################"
echo " Ortho-images calculation"
echo "##########################################################################"
echo " "
 
#############################################################################
# Generation of a map-projected ortho-images using the 20 m DEM 
#############################################################################

#######
img=002
#######

ortho=${dirout}/${name}_ortho_${ORTHO_PS}m_${img}_mapproj.tif
mapproject -t rpc --t_srs "+proj=utm +zone=$utm $NS +units=m +datum=WGS84" --threads ${nb_threads} --mpp ${ORTHO_PS} ${FULL_DEM} $img2 $rpc2 $ortho --bundle-adjust-prefix $BA_prefix
gdal_translate -co COMPRESS=LZW -a_nodata 0 -ot UInt16 $ortho tmp.tif
mv tmp.tif $ortho

band=red
ortho=${dirout}/${name}_ortho_${ORTHO_MS_PS}m_${img}_${band}_mapproj.tif
mapproject -t rpc --t_srs "+proj=utm +zone=$utm $NS +units=m +datum=WGS84" --threads ${nb_threads} --mpp ${ORTHO_MS_PS} ${FULL_DEM} $dirout/img2_${band}.tif $rpc2MS $ortho --bundle-adjust-prefix $BA_prefix
gdal_translate -co COMPRESS=LZW -a_nodata 0 -ot UInt16 $ortho tmp.tif
mv tmp.tif $ortho

band=gre
ortho=${dirout}/${name}_ortho_${ORTHO_MS_PS}m_${img}_${band}_mapproj.tif
mapproject -t rpc --t_srs "+proj=utm +zone=$utm $NS +units=m +datum=WGS84" --threads ${nb_threads} --mpp ${ORTHO_MS_PS} ${FULL_DEM} $dirout/img2_${band}.tif $rpc2MS $ortho --bundle-adjust-prefix $BA_prefix
gdal_translate -co COMPRESS=LZW -a_nodata 0 -ot UInt16 $ortho tmp.tif
mv tmp.tif $ortho

band=blu
ortho=${dirout}/${name}_ortho_${ORTHO_MS_PS}m_${img}_${band}_mapproj.tif
mapproject -t rpc --t_srs "+proj=utm +zone=$utm $NS +units=m +datum=WGS84" --threads ${nb_threads} --mpp ${ORTHO_MS_PS} ${FULL_DEM} $dirout/img2_${band}.tif $rpc2MS $ortho --bundle-adjust-prefix $BA_prefix
gdal_translate -co COMPRESS=LZW -a_nodata 0 -ot UInt16 $ortho tmp.tif
mv tmp.tif $ortho

band=nir
ortho=${dirout}/${name}_ortho_${ORTHO_MS_PS}m_${img}_${band}_mapproj.tif
mapproject -t rpc --t_srs "+proj=utm +zone=$utm $NS +units=m +datum=WGS84" --threads ${nb_threads} --mpp ${ORTHO_MS_PS} ${FULL_DEM} $dirout/img2_${band}.tif $rpc2MS $ortho --bundle-adjust-prefix $BA_prefix
gdal_translate -co COMPRESS=LZW -co TILED=YES -a_nodata 0 -ot UInt16 $ortho tmp.tif
mv tmp.tif $ortho

# Create PAN ortho
ulx=`gdalinfo $dirout/${name}_ortho_${ORTHO_PS}m_${img}_mapproj.tif | grep "Upper Left" | awk '{print $4}' | awk -F "," '{print $1}'`
uly=`gdalinfo $dirout/${name}_ortho_${ORTHO_PS}m_${img}_mapproj.tif | grep "Upper Left" | awk '{print $5}' | awk -F ")" '{print $1}'`
lrx=`gdalinfo $dirout/${name}_ortho_${ORTHO_PS}m_${img}_mapproj.tif | grep "Lower Right" | awk '{print $4}' | awk -F "," '{print $1}'`
lry=`gdalinfo $dirout/${name}_ortho_${ORTHO_PS}m_${img}_mapproj.tif | grep "Lower Right" | awk '{print $5}' | awk -F ")" '{print $1}'`
echo $ulx $uly $lrx $lry

gdal_translate -co COMPRESS=LZW -co TILED=YES -a_nodata 0 -ot UInt16 -a_ullr $ulx $uly $lrx $lry $dirout/${name}_ortho_${ORTHO_PS}m_${img}_mapproj.tif $dirout/${name}_ortho_${ORTHO_PS}m_${img}_mapproj_mask.tif
mv $dirout/${name}_ortho_${ORTHO_PS}m_${img}_mapproj_mask.tif ${dir}/${COR}/${name}_ORTHO_${COR}_PAN_${ORTHO_PS}m.tif

# Create MS orthos
ulx=`gdalinfo $dirout/${name}_ortho_${ORTHO_MS_PS}m_${img}_blu_mapproj.tif | grep "Upper Left" | awk '{print $4}' | awk -F "," '{print $1}'`
uly=`gdalinfo $dirout/${name}_ortho_${ORTHO_MS_PS}m_${img}_blu_mapproj.tif | grep "Upper Left" | awk '{print $5}' | awk -F ")" '{print $1}'`
lrx=`gdalinfo $dirout/${name}_ortho_${ORTHO_MS_PS}m_${img}_blu_mapproj.tif | grep "Lower Right" | awk '{print $4}' | awk -F "," '{print $1}'`
lry=`gdalinfo $dirout/${name}_ortho_${ORTHO_MS_PS}m_${img}_blu_mapproj.tif | grep "Lower Right" | awk '{print $5}' | awk -F ")" '{print $1}'`
echo $ulx $uly $lrx $lry

gdal_translate -a_nodata 0 -ot UInt16 -a_ullr $ulx $uly $lrx $lry $dirout/${name}_ortho_${ORTHO_MS_PS}m_${img}_blu_mapproj.tif $dirout/${name}_ortho_${ORTHO_MS_PS}m_${img}_blu_mapproj_shifted_mask.tif 
gdal_translate -a_nodata 0 -ot UInt16 -a_ullr $ulx $uly $lrx $lry $dirout/${name}_ortho_${ORTHO_MS_PS}m_${img}_gre_mapproj.tif $dirout/${name}_ortho_${ORTHO_MS_PS}m_${img}_gre_mapproj_shifted_mask.tif 
gdal_translate -a_nodata 0 -ot UInt16 -a_ullr $ulx $uly $lrx $lry $dirout/${name}_ortho_${ORTHO_MS_PS}m_${img}_red_mapproj.tif $dirout/${name}_ortho_${ORTHO_MS_PS}m_${img}_red_mapproj_shifted_mask.tif 
gdal_translate -a_nodata 0 -ot UInt16 -a_ullr $ulx $uly $lrx $lry $dirout/${name}_ortho_${ORTHO_MS_PS}m_${img}_nir_mapproj.tif $dirout/${name}_ortho_${ORTHO_MS_PS}m_${img}_nir_mapproj_shifted_mask.tif 

# Merge the MS orthos in a single 3-band image
R=$dirout/${name}_ortho_${ORTHO_MS_PS}m_${img}_red_mapproj_shifted_mask.tif
G=$dirout/${name}_ortho_${ORTHO_MS_PS}m_${img}_gre_mapproj_shifted_mask.tif
B=$dirout/${name}_ortho_${ORTHO_MS_PS}m_${img}_blu_mapproj_shifted_mask.tif
N=$dirout/${name}_ortho_${ORTHO_MS_PS}m_${img}_nir_mapproj_shifted_mask.tif

otbcli_ConcatenateImages -il $R $G $B $N -out tmp.tif uint16
gdal_translate -co COMPRESS=LZW -co TILED=YES tmp.tif $dirout/${name}_ortho_${ORTHO_MS_PS}m_${img}_RGBN_mapproj_mask.tif 
rm $R $G $B $N tmp.tif

mv $dirout/${name}_ortho_${ORTHO_MS_PS}m_${img}_RGBN_mapproj_mask.tif ${dir}/${COR}/${name}_ORTHO_${COR}_MS_${ORTHO_MS_PS}m.tif








