#!/bin/sh
# run using: nohup 0.DEM_stereo_seedDEM_with_MSorthos_BM_SGM_MGM_vrt.sh > nohup.txt &

# Work on PHR stereo pairs
# GLO-30 DEM is used as seed (=Rough_DEM) for map_projecting the images

logfile=nohup.txt

. /data/icesat/travail_en_cours/jerome/PGO/scripts/lasfunciones.sh
dirasp=/data/icesat/travail_sauve/Etienne/ASP/StereoPipeline-3.0.0-2021-10-05-x86_64-Linux
dirotb=/data/icesat/travail_sauve/Etienne/OTB/OTB-7.2.0-Linux64
path_resume=/home/l/lebreton/Documents/Legos/scripts/file_resume_new.sh
export PATH=$dirasp/bin:$dirotb/bin:$HOME/bin:$PATH

echo "Version of ASP" $dirasp
echo "Start time :"
date

echo " "
echo "##########################################################################"
echo " PHR, SPOT6-7 DEM extraction using ASP, and a seed DEM"
echo " Create map-projected PAN, MS, pansharpened ortho-images"
echo "##########################################################################"
echo " "

nb_threads=8
date=$1
COR=$3

Rough_DEM_full=/data/icesat/produits/Global_DEM/GLO-30m-DTED/GLO-30_Glaciers.vrt 

dir=$1
diro=${dir}/${COR}
mkdir $diro
dirout=${dir}/${COR}/tmp
mkdir $dirout

SENSOR=`ls ${dir} | grep "P_001" | awk -F"_" '{print $2}'`
EXT=`ls ${dir}/IMG_${SENSOR}_P_001 | grep "IMG" | head -2 | tail -1 | awk -F"." '{print $2}'`
echo "sensor" $SENSOR 
echo "extension" $EXT
echo $COR

name=$2

echo "##########################################################################"
echo "DEM calculation"
echo "##########################################################################"
echo ""

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

name_bb=$(echo "$dir" | awk -F"/" '{print $NF}')
outpath_bb=$dir/${name_bb}_GLO30.tif
outpath_bb2=$dir/${name_bb}_GLO30_UTM.tif

gdalwarp -t_srs '+proj=longlat +datum=WGS84 +no_defs' -tr 0.00027 0.00027 -te $boundingbox -r cubic $Rough_DEM_full  $outpath_bb
gdalwarp -t_srs "+proj=utm +zone=$utm $NS +units=m +datum=WGS84" -tr 30 30 -r cubic $outpath_bb $outpath_bb2

#############################################################################
# Chhose the resolution of the different DEMs
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
        otbcli_SplitImage -in $img1MS -out $dirout/img.tif
        mv $dirout/img_0.tif $img1red
        mv $dirout/img_1.tif $img1gre
        mv $dirout/img_2.tif $img1blu
        mv $dirout/img_3.tif $img1nir
        rm $dirout/*.geom
fi

img2red=$dirout/img2_red.tif
img2gre=$dirout/img2_gre.tif
img2blu=$dirout/img2_blu.tif
img2nir=$dirout/img2_nir.tif
if [ ! -e $img2red ] ; then
        otbcli_SplitImage -in $img2MS -out $dirout/img.tif
        mv $dirout/img_0.tif $img2red
        mv $dirout/img_1.tif $img2gre
        mv $dirout/img_2.tif $img2blu
        mv $dirout/img_3.tif $img2nir
        rm $dirout/*.geom
fi

#############################################################################
# Extract longitude/latitude of the center of the image & define the UTM zone + value of the NS variable
#############################################################################

lon=`more $dir1/DIM_* | grep "<LON>" | tail -1 | awk -F">" '{print $2}'| awk -F"<" '{print $1}'`
lat=`more $dir1/DIM_* | grep "<LAT>" | tail -1 | awk -F">" '{print $2}'| awk -F"<" '{print $1}'`
utm=`echo "($lon + 180)/6.+1" | bc`

if [ $(echo "$lat > 0" | bc -l) -eq 1 ]; then
    echo "NORTH"
    NS=+north
    azimuth=337.5 # from http://dx.doi.org/10.1080/15230406.2016.1185647
fi

if [ $(echo "$lat < 0" | bc -l) -eq 1 ]; then
    echo "SOUTH"
    NS=+south
    azimuth=337.5 # from http://dx.doi.org/10.1080/15230406.2016.1185647
fi


#############################################################################
# Choose here to perform the bundle adjustment or not			    #
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
# Generation of the DEM at different resolution including a point2dem ortho-image# 
##################################################################################

mapproject --ot UInt16 --nodata-value 0 -t rpc --t_srs "+proj=utm +zone=$utm $NS +units=m +datum=WGS84" --threads ${nb_threads} --mpp ${ORTHO_PS} $outpath_bb $img1 $rpc1 $dirout/img1_mapproj.tif --bundle-adjust-prefix $BA_prefix
mapproject --ot UInt16 --nodata-value 0 -t rpc --t_srs "+proj=utm +zone=$utm $NS +units=m +datum=WGS84" --threads ${nb_threads} --mpp ${ORTHO_PS} $outpath_bb $img2 $rpc2 $dirout/img2_mapproj.tif --bundle-adjust-prefix $BA_prefix

if [ "$COR" = MGM ]; then
echo "DEM computed using the $MGM algorithm, with Dave Shean parameters, https://zenodo.org/record/4533679"
settings=stereo.default_MGM_DS_210218
parallel_stereo --processes 3 --threads-multiprocess 6 --threads-singleprocess 24 \
                -t rpcmaprpc -s $settings \
                $dirout/img1_mapproj.tif $dirout/img2_mapproj.tif $rpc1 $rpc2 $dirout/$name ${outpath_bb}
fi

if [ "$COR" = SGM ]; then
echo "DEM computed using the $SGM (Semi Global Matching) algorithm, with Deschamps-Berger_TC_2020 parameters"
settings=stereo.default_SGM191015_Cesar
parallel_stereo --corr-tile-size 1600 --corr-timeout 900 --threads-multiprocess 4 \
                --threads-singleprocess 15 --processes 4 -t rpcmaprpc -s $settings \
                $dirout/img1_mapproj.tif $dirout/img2_mapproj.tif $rpc1 $rpc2 $dirout/$name ${outpath_bb}
fi

if [ "$COR" = BM ]; then
echo "DEM computed using the $COR Block Matching algorithm"
settings=stereo.default.Int
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



FULL_DEM=${dir}/${COR}/${name}_DEM_${COR}_WGS84_${DEM_PS2}m.tif

echo " "
echo "*********************************************************"
echo "DEM coregistration with GLO30"
echo "*********************************************************"
echo " "

#############################################################################
# Need to clean exported variables because of conflicts
#############################################################################

env -i
export PATH=/home/l/lebreton/demcoreg/demcoreg/:$PATH
export PATH=/home/l/lebreton/miniconda3/bin/:$PATH

#############################################################################
# Use Nuth and Kaab coregistration
#############################################################################

dem_align.py -mask_list=glaciers $dir/${name_bb}_GLO30_UTM.tif ${dir}/${COR}/${name}_DEM_${COR}_${DEM_PS2}m.tif

#############################################################################
# Apply coregistration values on Pleiade DEM
#############################################################################

delta_repertory=`ls ${dir}/${COR} | grep "WGS84_20m_dem_align"`
delta_path_repertory=${dir}/${COR}/${delta_repertory}
dz=`ls $delta_path_repertory | grep ".json" | awk -F"_" '{print $(NF-2)}' | awk '{print substr($0,2,4)}'`
dy=`ls $delta_path_repertory | grep ".json" | awk -F"_" '{print $(NF-3)}' | awk '{print substr($0,2,4)}'`
dx=`ls $delta_path_repertory | grep ".json" | awk -F"_" '{print $(NF-4)}' | awk '{print substr($0,2,4)}'`

ulx=`gdalinfo ${dir}/${COR}/${name}_DEM_${COR}_${DEM_PS}m.tif | grep "Upper Left" | awk '{print $4}' | awk -F "," '{print $1}'`
uly=`gdalinfo ${dir}/${COR}/${name}_DEM_${COR}_${DEM_PS}m.tif | grep "Upper Left" | awk '{print $5}' | awk -F ")" '{print $1}'`
lrx=`gdalinfo ${dir}/${COR}/${name}_DEM_${COR}_${DEM_PS}m.tif | grep "Lower Right" | awk '{print $4}' | awk -F "," '{print $1}'`
lry=`gdalinfo ${dir}/${COR}/${name}_DEM_${COR}_${DEM_PS}m.tif | grep "Lower Right" | awk '{print $5}' | awk -F ")" '{print $1}'`
echo $ulx $uly $lrx $lry

ulx2=`echo "$ulx$dx" | bc -l`
lrx2=`echo "$lrx$dx" | bc -l`
uly2=`echo "$uly$dy" | bc -l`
lry2=`echo "$lry$dy" | bc -l`
echo $ulx2 $uly2 $lrx2 $lry2


gdal_translate -co COMPRESS=LZW -co TILED=YES -a_nodata 0 -ot UInt16 -a_ullr $ulx2 $uly2 $lrx2 $lry2 ${dir}/${COR}/${name}_DEM_${COR}_WGS84_${DEM_PS1}m.tif ${dir}/${COR}/${name}_DEM_${COR}_WGS84_${DEM_PS1}m_shifted.tif
rm -r ${dir}/${COR}/${name}_DEM_${COR}_WGS84_${DEM_PS1}m.tif
gdal_calc.py -A ${dir}/${COR}/${name}_DEM_${COR}_WGS84_${DEM_PS1}m_shifted.tif --outfile=${dir}/${COR}/${name}_DEM_${COR}_WGS84_${DEM_PS1}m.tif --calc="(A$dz)"
rm -r ${dir}/${COR}/${name}_DEM_${COR}_WGS84_${DEM_PS1}m_shifted.tif

gdal_translate -co COMPRESS=LZW -co TILED=YES -a_nodata 0 -ot UInt16 -a_ullr $ulx2 $uly2 $lrx2 $lry2 ${dir}/${COR}/${name}_DEM_${COR}_WGS84_${DEM_PS1}m.tif ${dir}/${COR}/${name}_DEM_${COR}_WGS84_${DEM_PS1}m_shifted.tif
rm -r ${dir}/${COR}/${name}_DEM_${COR}_WGS84_${DEM_PS1}m.tif
gdal_calc.py -A ${dir}/${COR}/${name}_DEM_${COR}_WGS84_${DEM_PS1}m_shifted.tif --outfile=${dir}/${COR}/${name}_DEM_${COR}_WGS84_${DEM_PS1}m.tif --calc="(A$dz)"
rm -r ${dir}/${COR}/${name}_DEM_${COR}_WGS84_${DEM_PS1}m_shifted.tif


FULL_DEM=${dir}/${COR}/${name}_DEM_${COR}_${DEM_PS}m.tif

#############################################################################
# Generation of a map-projected ortho-images using the 20 m DEM 
#############################################################################
#######
img=002
#######

BA_prefix=${dirout}/ba_run_NO/out

ortho=$dirout/${name}_ortho_${ORTHO_PS}m_${img}_mapproj.tif
echo $ortho
mapproject -t rpc --t_srs "+proj=utm +zone=$utm $NS +units=m +datum=WGS84" --threads ${nb_threads} --mpp ${ORTHO_PS} ${FULL_DEM} $img1 $rpc1 $ortho --bundle-adjust-prefix $BA_prefix
gdal_translate -co COMPRESS=LZW -a_nodata 0 -ot UInt16 $ortho tmp.tif
mv tmp.tif $ortho

band=red
ortho=$dirout/${name}_ortho_${ORTHO_MS_PS}m_${img}_${band}_mapproj.tif
mapproject -t rpc --t_srs "+proj=utm +zone=$utm $NS +units=m +datum=WGS84" --threads ${nb_threads} --mpp ${ORTHO_MS_PS} ${FULL_DEM} $dirout/img1_${band}.tif $rpc1MS $ortho --bundle-adjust-prefix $BA_prefix
gdal_translate -co COMPRESS=LZW -a_nodata 0 -ot UInt16 $ortho tmp.tif
mv tmp.tif $ortho

band=gre
ortho=$dirout/${name}_ortho_${ORTHO_MS_PS}m_${img}_${band}_mapproj.tif
mapproject -t rpc --t_srs "+proj=utm +zone=$utm $NS +units=m +datum=WGS84" --threads ${nb_threads} --mpp ${ORTHO_MS_PS} ${FULL_DEM} $dirout/img1_${band}.tif $rpc1MS $ortho --bundle-adjust-prefix $BA_prefix
gdal_translate -co COMPRESS=LZW -a_nodata 0 -ot UInt16 $ortho tmp.tif
mv tmp.tif $ortho

band=blu
ortho=$dirout/${name}_ortho_${ORTHO_MS_PS}m_${img}_${band}_mapproj.tif
mapproject -t rpc --t_srs "+proj=utm +zone=$utm $NS +units=m +datum=WGS84" --threads ${nb_threads} --mpp ${ORTHO_MS_PS} ${FULL_DEM} $dirout/img1_${band}.tif $rpc1MS $ortho --bundle-adjust-prefix $BA_prefix
gdal_translate -co COMPRESS=LZW -a_nodata 0 -ot UInt16 $ortho tmp.tif
mv tmp.tif $ortho

band=nir
ortho=$dirout/${name}_ortho_${ORTHO_MS_PS}m_${img}_${band}_mapproj.tif
mapproject -t rpc --t_srs "+proj=utm +zone=$utm $NS +units=m +datum=WGS84" --threads ${nb_threads} --mpp ${ORTHO_MS_PS} ${FULL_DEM} $dirout/img1_${band}.tif $rpc1MS $ortho --bundle-adjust-prefix $BA_prefix
gdal_translate -co COMPRESS=LZW -co TILED=YES -a_nodata 0 -ot UInt16 $ortho tmp.tif
mv tmp.tif $ortho


#############################################################################
# Apply coregistration values on the map-projected ortho-images
#############################################################################

ulx=`gdalinfo $dirout/${name}_ortho_${ORTHO_PS}m_${img}_mapproj.tif | grep "Upper Left" | awk '{print $4}' | awk -F "," '{print $1}'`
uly=`gdalinfo $dirout/${name}_ortho_${ORTHO_PS}m_${img}_mapproj.tif | grep "Upper Left" | awk '{print $5}' | awk -F ")" '{print $1}'`
lrx=`gdalinfo $dirout/${name}_ortho_${ORTHO_PS}m_${img}_mapproj.tif | grep "Lower Right" | awk '{print $4}' | awk -F "," '{print $1}'`
lry=`gdalinfo $dirout/${name}_ortho_${ORTHO_PS}m_${img}_mapproj.tif | grep "Lower Right" | awk '{print $5}' | awk -F ")" '{print $1}'`
echo $ulx $uly $lrx $lry

ulx2=`echo "$ulx$dx" | bc -l`
lrx2=`echo "$lrx$dx" | bc -l`
uly2=`echo "$uly$dy" | bc -l`
lry2=`echo "$lry$dy" | bc -l`
echo $ulx2 $uly2 $lrx2 $lry2

gdal_translate -co COMPRESS=LZW -co TILED=YES -a_nodata 0 -ot UInt16 -a_ullr $ulx2 $uly2 $lrx2 $lry2 $dirout/${name}_ortho_${ORTHO_PS}m_${img}_mapproj.tif $dirout/${name}_ortho_${ORTHO_PS}m_${img}_mapproj_shifted_xy_mask.tif

gdaladdo --config COMPRESS_OVERVIEW JPEG --config INTERLEAVE_OVERVIEW PIXEL -r average $dirout/${name}_ortho_${ORTHO_PS}m_${img}_mapproj_shifted_xy.tif 4 16
gdal_translate -ot Byte -scale -tr 10 10 $dirout/${name}_ortho_${ORTHO_PS}m_${img}_mapproj_shifted_xy.tif $dirout/${name}_ortho_${ORTHO_PS}m_${img}_mapproj_shifted_sm_xy.tif
convert -resize 1200 $dirout/${name}_ortho_${ORTHO_PS}m_${img}_mapproj_shifted_sm_xy.tif $dirout/${name}_ortho_${ORTHO_PS}m_${img}_mapproj_shifted_xy.jpg

#rm $dirout/${name}_ortho_${ORTHO_PS}m_${img}_mapproj.tif $dirout/${name}_ortho_${ORTHO_PS}m_${img}_mapproj_shifted_sm.tif
mv $dirout/${name}_ortho_${ORTHO_PS}m_${img}_mapproj_shifted_xy_mask.tif ${dir}/${COR}/${name}_ortho_${COR}_PAN_${ORTHO_PS}m.tif

# APPLY the same shift to four MS images
ulx=`gdalinfo $dirout/${name}_ortho_${ORTHO_MS_PS}m_${img}_blu_mapproj.tif | grep "Upper Left" | awk '{print $4}' | awk -F "," '{print $1}'`
uly=`gdalinfo $dirout/${name}_ortho_${ORTHO_MS_PS}m_${img}_blu_mapproj.tif | grep "Upper Left" | awk '{print $5}' | awk -F ")" '{print $1}'`
lrx=`gdalinfo $dirout/${name}_ortho_${ORTHO_MS_PS}m_${img}_blu_mapproj.tif | grep "Lower Right" | awk '{print $4}' | awk -F "," '{print $1}'`
lry=`gdalinfo $dirout/${name}_ortho_${ORTHO_MS_PS}m_${img}_blu_mapproj.tif | grep "Lower Right" | awk '{print $5}' | awk -F ")" '{print $1}'`
echo $ulx $uly $lrx $lry

ulx2=`echo "$ulx$dx" | bc -l`
lrx2=`echo "$lrx$dx" | bc -l`
uly2=`echo "$uly$dy" | bc -l`
lry2=`echo "$lry$dy" | bc -l`

gdal_translate -a_nodata 0 -ot UInt16 -a_ullr $ulx2 $uly2 $lrx2 $lry2 $dirout/${name}_ortho_${ORTHO_MS_PS}m_${img}_blu_mapproj.tif $dirout/${name}_ortho_${ORTHO_MS_PS}m_${img}_blu_mapproj_shifted_mask.tif 
gdal_translate -a_nodata 0 -ot UInt16 -a_ullr $ulx2 $uly2 $lrx2 $lry2 $dirout/${name}_ortho_${ORTHO_MS_PS}m_${img}_gre_mapproj.tif $dirout/${name}_ortho_${ORTHO_MS_PS}m_${img}_gre_mapproj_shifted_mask.tif 
gdal_translate -a_nodata 0 -ot UInt16 -a_ullr $ulx2 $uly2 $lrx2 $lry2 $dirout/${name}_ortho_${ORTHO_MS_PS}m_${img}_red_mapproj.tif $dirout/${name}_ortho_${ORTHO_MS_PS}m_${img}_red_mapproj_shifted_mask.tif 
gdal_translate -a_nodata 0 -ot UInt16 -a_ullr $ulx2 $uly2 $lrx2 $lry2 $dirout/${name}_ortho_${ORTHO_MS_PS}m_${img}_nir_mapproj.tif $dirout/${name}_ortho_${ORTHO_MS_PS}m_${img}_nir_mapproj_shifted_mask.tif 
rm $dirout/${name}_ortho_${ORTHO_MS_PS}m_${img}_blu_mapproj.tif
rm $dirout/${name}_ortho_${ORTHO_MS_PS}m_${img}_gre_mapproj.tif
rm $dirout/${name}_ortho_${ORTHO_MS_PS}m_${img}_red_mapproj.tif
rm $dirout/${name}_ortho_${ORTHO_MS_PS}m_${img}_nir_mapproj.tif

# Merge the MS orthos in a single 3-band image
R=$dirout/${name}_ortho_${ORTHO_MS_PS}m_${img}_red_mapproj_shifted_mask.tif
G=$dirout/${name}_ortho_${ORTHO_MS_PS}m_${img}_gre_mapproj_shifted_mask.tif
B=$dirout/${name}_ortho_${ORTHO_MS_PS}m_${img}_blu_mapproj_shifted_mask.tif
N=$dirout/${name}_ortho_${ORTHO_MS_PS}m_${img}_nir_mapproj_shifted_mask.tif

otbcli_ConcatenateImages -il $R $G $B $N -out tmp.tif uint16
gdal_translate -co COMPRESS=LZW -co TILED=YES tmp.tif $dirout/${name}_ortho_${ORTHO_MS_PS}m_${img}_RGBN_mapproj_shifted_xy_mask.tif 
convert -resize 1200 $dirout/${name}_ortho_${ORTHO_MS_PS}m_${img}_RGBN_mapproj_shifted_xy.tif $dirout/${name}_ortho_${ORTHO_MS_PS}m_${img}_RGBN_mapproj_shifted_xy.jpg
gdaladdo --config COMPRESS_OVERVIEW JPEG --config INTERLEAVE_OVERVIEW PIXEL -r average $dirout/${name}_ortho_${ORTHO_MS_PS}m_${img}_RGBN_mapproj_shifted_xy.tif 4 16
rm $R $G $B $N tmp.tif

mv $dirout/${name}_ortho_${ORTHO_MS_PS}m_${img}_RGBN_mapproj_shifted_xy_mask.tif ${dir}/${COR}/${name}_ortho_${COR}_MS_${ORTHO_MS_PS}m.tif


echo " "
echo "*********************************************************"
echo "Create HTML file"
echo "*********************************************************"
echo " "

path_resume=/home/l/lebreton/Documents/Legos/workflow/LOCAL/coregistration/file_resume.sh

#############################################################################
# Get original image name and preview DEM
#############################################################################

name_img1=`more $dir1/DIM_* | grep "DATASET_NAME" | awk -F">" '{print $2}'| awk -F"<" '{print $1}'`
name_img2=`more $dir2/DIM_* | grep "DATASET_NAME" | awk -F">" '{print $2}'| awk -F"<" '{print $1}'`

path_dem_coreg_dir=${dir}/${COR}/${name}_DEM_${COR}_${DEM_PS2}m_dem_align
path_dem_coreg_preview=`ls ${path_dem_coreg_dir} | grep "preview"`

mv ${path_dem_coreg_dir}/$path_dem_coreg_preview ${dir}/${COR}/PREVIEW_${name}_DEM_${COR}_${DEM_PS2}m_dem_align.png

EPSG=`gdalinfo ${dir}/${COR}/${name}_DEM_${COR}_${DEM_PS2}m.tif | grep "ID" | tail -1 | awk -F"," '{print $2}' | awk -F"]" '{print $1}'`

sh $path_resume $name_img1 $name_img2 ${dir}/${COR} $utm $H $EPSG ${dir}/${COR}/PREVIEW_${name}_DEM_${COR}_${DEM_PS2}m_dem_align.png ${COR}

#############################################################################
# Get coregistred DEM and clean repertory 
#############################################################################

path_dem_coreg_dir_WGS84_20m=${dir}/${COR}/${name}_DEM_${COR}_${DEM_PS2}m_dem_align
path_dem_coreg_WGS84_20m=`ls ${path_dem_coreg_dir_WGS84_20m} | grep "align.tif"`
#mv $path_dem_coreg_WGS84_20m ${dir}/${COR}/${name}_DEM_${COR}_WGS84_${DEM_PS2}m_coreg.tif

rm -r $dirout/
rm -r $path_dem_coreg_dir_WGS84_20m/



































