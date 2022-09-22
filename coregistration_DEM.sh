#!/bin/sh

############################################
##       Path to dependencies           ####
############################################

export PATH=/home/l/lebreton/demcoreg/demcoreg/:$PATH
export PATH=/home/l/lebreton/miniconda3/bin/:$PATH

############################################
##             Parameters               ####
############################################

dir=/home/l/lebreton/Documents/Legos/workflow/Github/Bologna_WNA/ # Directory with DEM and ORTHO 
COR=BM # Choose Block Matching (BM) or Semi Global Matching (SGM)
name=Bologna # Output prefix for DEM and orthos
reference_dem=/home/l/lebreton/Documents/Legos/workflow/Github/Bologna_WNA/Bologna_GLO30_UTM.tif # link to reference DEM in UTM projection
dem_2m=/home/l/lebreton/Documents/Legos/workflow/Github/Bologna_WNA/BM/Bologna_DEM_BM_2m.tif
dem_20m=/home/l/lebreton/Documents/Legos/workflow/Github/Bologna_WNA/BM/Bologna_DEM_BM_20m.tif
ortho_ms=/home/l/lebreton/Documents/Legos/workflow/Github/Bologna_WNA/BM/Bologna_ORTHO_BM_MS_2m.tif
ortho_pan=/home/l/lebreton/Documents/Legos/workflow/Github/Bologna_WNA/BM/Bologna_ORTHO_BM_PAN_0.5m.tif

#############################################################################
# Use Nuth and Kaab coregistration
#############################################################################

dem_align.py -mask_list=glaciers $reference_dem $dem_20m

#############################################################################
# Apply coregistration values on Pleiades DEM
#############################################################################

delta_repertory=`ls ${dir}/${COR} | grep "_dem_align"| grep "20m"`
delta_path_repertory=${dir}/${COR}/${delta_repertory}

dz=`ls $delta_path_repertory | grep ".json" | awk -F"_" '{print $(NF-2)}' | awk '{print substr($0,2,6)}'`
dy=`ls $delta_path_repertory | grep ".json" | awk -F"_" '{print $(NF-3)}' | awk '{print substr($0,2,6)}'`
dx=`ls $delta_path_repertory | grep ".json" | awk -F"_" '{print $(NF-4)}' | awk '{print substr($0,2,6)}'`
echo $dx $dy $dz

# Apply coregistration on DEM at 2m
ulx=`gdalinfo ${dem_2m} | grep "Upper Left" | awk '{print $4}' | awk -F "," '{print $1}'`
uly=`gdalinfo ${dem_2m} | grep "Upper Left" | awk '{print $5}' | awk -F ")" '{print $1}'`
lrx=`gdalinfo ${dem_2m} | grep "Lower Right" | awk '{print $4}' | awk -F "," '{print $1}'`
lry=`gdalinfo ${dem_2m} | grep "Lower Right" | awk '{print $5}' | awk -F ")" '{print $1}'`
echo $ulx $uly $lrx $lry

ulx2=`echo "${ulx}${dx}" | bc -l`
lrx2=`echo "${lrx}${dx}" | bc -l`
uly2=`echo "${uly}${dy}" | bc -l`
lry2=`echo "${lry}${dy}" | bc -l`
echo $ulx2 $uly2 $lrx2 $lry2

#gdal_translate -co COMPRESS=LZW -co TILED=YES -a_nodata -9999 -ot Float32 -a_ullr $ulx2 $uly2 $lrx2 $lry2 ${dem_2m} ${dir}/${COR}/${name}_DEM_${COR}_2m_shifted_xy.tif
mkdir ${dir}/${COR}/original_dem
mv ${dem_2m} ${dir}/${COR}/original_dem/${name}_DEM_${COR}_2m_original.tif
gdal_calc.py -A ${dir}/${COR}/${name}_DEM_${COR}_2m_shifted_xy.tif --outfile=${dir}/${COR}/${name}_DEM_${COR}_2m_shifted.tif --calc="(A$dz)"
rm -r ${dir}/${COR}/${name}_DEM_${COR}_2m_shifted_xy.tif

# Apply coregistration on DEM at 20m
ulx=`gdalinfo ${dem_20m} | grep "Upper Left" | awk '{print $4}' | awk -F "," '{print $1}'`
uly=`gdalinfo ${dem_20m} | grep "Upper Left" | awk '{print $5}' | awk -F ")" '{print $1}'`
lrx=`gdalinfo ${dem_20m} | grep "Lower Right" | awk '{print $4}' | awk -F "," '{print $1}'`
lry=`gdalinfo ${dem_20m} | grep "Lower Right" | awk '{print $5}' | awk -F ")" '{print $1}'`
echo $ulx $uly $lrx $lry

ulx2=`echo "${ulx}${dx}" | bc -l`
lrx2=`echo "${lrx}${dx}" | bc -l`
uly2=`echo "${uly}${dy}" | bc -l`
lry2=`echo "${lry}${dy}" | bc -l`
echo $ulx2 $uly2 $lrx2 $lry2

gdal_translate -co COMPRESS=LZW -co TILED=YES -a_nodata -9999 -ot Float32 -a_ullr $ulx2 $uly2 $lrx2 $lry2 ${dem_20m} ${dir}/${COR}/${name}_DEM_${COR}_20m_shifted_xy.tif
mkdir ${dir}/${COR}/original_dem
mv ${dem_20m} ${dir}/${COR}/original_dem/${name}_DEM_${COR}_20m_original.tif
gdal_calc.py -A ${dir}/${COR}/${name}_DEM_${COR}_20m_shifted_xy.tif --outfile=${dir}/${COR}/${name}_DEM_${COR}_20m_shifted.tif --calc="(A$dz)"
rm -r ${dir}/${COR}/${name}_DEM_${COR}_20m_shifted_xy.tif


#############################################################################
# Apply coregistration values on ortho-images
#############################################################################

# APPLY the shift to PAN image
ulx=`gdalinfo $ortho_pan | grep "Upper Left" | awk '{print $4}' | awk -F "," '{print $1}'`
uly=`gdalinfo $ortho_pan | grep "Upper Left" | awk '{print $5}' | awk -F ")" '{print $1}'`
lrx=`gdalinfo $ortho_pan | grep "Lower Right" | awk '{print $4}' | awk -F "," '{print $1}'`
lry=`gdalinfo $ortho_pan | grep "Lower Right" | awk '{print $5}' | awk -F ")" '{print $1}'`
echo $ulx $uly $lrx $lry

ulx2=`echo "${ulx}${dx}" | bc -l`
lrx2=`echo "${lrx}${dx}" | bc -l`
uly2=`echo "${uly}${dy}" | bc -l`
lry2=`echo "${lry}${dy}" | bc -l`
echo $ulx2 $uly2 $lrx2 $lry2

gdal_translate -co COMPRESS=LZW -co TILED=YES -a_nodata 0 -ot UInt16 -a_ullr $ulx2 $uly2 $lrx2 $lry2 $ortho_pan ${dir}/${COR}/${name}_ORTHO_${COR}_PAN_0.5m_shifted.tif
mv $ortho_pan ${dir}/${COR}/original_dem/${name}_ORTHO_${COR}_PAN_0.5m_original.tif

# APPLY the shift to MS image
ulx=`gdalinfo $ortho_ms | grep "Upper Left" | awk '{print $4}' | awk -F "," '{print $1}'`
uly=`gdalinfo $ortho_ms | grep "Upper Left" | awk '{print $5}' | awk -F ")" '{print $1}'`
lrx=`gdalinfo $ortho_ms | grep "Lower Right" | awk '{print $4}' | awk -F "," '{print $1}'`
lry=`gdalinfo $ortho_ms | grep "Lower Right" | awk '{print $5}' | awk -F ")" '{print $1}'`
echo $ulx $uly $lrx $lry

ulx2=`echo "${ulx}${dx}" | bc -l`
lrx2=`echo "${lrx}${dx}" | bc -l`
uly2=`echo "${uly}${dy}" | bc -l`
lry2=`echo "${lry}${dy}" | bc -l`
echo $ulx2 $uly2 $lrx2 $lry2

gdal_translate -co COMPRESS=LZW -co TILED=YES -a_nodata 0 -ot UInt16 -a_ullr $ulx2 $uly2 $lrx2 $lry2 $ortho_ms ${dir}/${COR}/${name}_ORTHO_${COR}_MS_2m_shifted.tif
mv $ortho_ms ${dir}/${COR}/original_dem/${name}_ORTHO_${COR}_MS_2m_original.tif









