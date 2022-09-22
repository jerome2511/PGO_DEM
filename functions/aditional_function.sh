#!/bin/bash

isn93='+proj=lcc +lat_1=64.25 +lat_2=65.75 +lat_0=65 +lon_0=-19 +x_0=500000 +y_0=500000 +ellps=WGS84 +datum=WGS84 +units=m +no_defs'
isn2016='+proj=lcc +lat_1=64.25 +lat_2=65.75 +lat_0=65 +lon_0=-19 +x_0=2700000 +y_0=300000 +ellps=GRS80 +units=m +no_defs'
utm28='+proj=utm +zone=28 +ellps=WGS84 +datum=WGS84 +units=m +no_defs'
lzwparam='-co compress=lzw -co tiled=yes -co blockxsize=512 -co blockysize=512 -co predictor=2'
lzwparampy='--co compress=lzw --co tiled=yes --co blockxsize=512 --co blockysize=512 --co predictor=2'
demzstd='-co compress=zstd -co tiled=yes -co blockxsize=512 -co blockysize=512 -co predictor=2 -co zstd_level=15 -co num_threads=32'
imgzstd='-co compress=zstd -co tiled=yes -co bigtiff=yes -co blockxsize=1024 -co blockysize=1024 -co predictor=2 -co zstd_level=1 -co num_threads=32'
demzstdpy='--co compress=zstd --co tiled=yes --co blockxsize=512 --co blockysize=512 --co predictor=2 --co zstd_level=15 --co num_threads=32'

geoid2016=/u01/jmcb/geodesy/geoid/Icegeoid_ISN2016.gtx
geoid93=/u01/jmcb/geodesy/geoid/Icegeoid_ISN93.gtx

get_georef()
{
    gdalinfo -nomd -norat $1 \
        | egrep -e 'Lower Left|Upper Right' \
        | sed -e 's/[,()]//g' \
        | sed -e 's/-/ -/g' \
        | awk '{print $3,$4,$10,$11}' \
        | tr '\n' ' '
}

get_ullr()
{
    gdalinfo -nomd -norat $1 \
        | egrep -e 'Upper Left|Lower Right' \
        | sed -e 's/[,()]//g' \
        | sed -e 's/-/ -/g' \
        | awk '{print $3,$4,$10,$11}' \
        | tr '\n' ' '
}

get_px()
{
    gdalinfo -nomd -norat $1 \
        | grep 'Pixel Size' \
        | sed -e 's/)//g' \
        | awk -F ",-" '{print $2}'
}

get_ty()
{
    gdalinfo -nomd -norat $1 \
        | grep 'Type' \
        | awk '{print $4}' \
        | sed -e 's/[,()]//g' \
        | awk -F "=" '{print $2}'
}

get_proj()
{
    gdalsrsinfo --single-line -o proj4 $1
}


geo2ell_isn2016()
{
    NAM=$(basename "$1" | sed 's/.\{4\}$//')
    DIR=$(dirname "$1")
    gdalwarp -overwrite -r cubic -te $(get_georef $1) -tr $(get_px $1) $(get_px $1) \
        -t_srs "$(get_proj $1)" $lzwparam -of GTiff $geoid2016 ~/cal/geoid_frm_${NAM}.tif
    gdal_calc.py --overwrite -A $1 -B ~/cal/geoid_frm_${NAM}.tif \
        --outfile $DIR/${NAM}_zmae.tif --calc="A+B" $demzstdpy --type Float32
    rm ~/cal/geoid_frm_${NAM}.tif
}

ell2geo_isn2016()
{
    NAM=$(basename "$1" | sed 's/.\{4\}$//')
    DIR=$(dirname "$1")
    gdalwarp -overwrite -r cubic -te $(get_georef $1) -tr $(get_px $1) $(get_px $1) \
        -t_srs "$(get_proj $1)" $lzwparam -of GTiff $geoid2016 ~/cal/geoid_frm_${NAM}.tif
    gdal_calc.py --overwrite -A $1 -B ~/cal/geoid_frm_${NAM}.tif \
        --outfile $DIR/${NAM}_zmasl.tif --calc="A-B" $demzstdpy --type Float32
    rm ~/cal/geoid_frm_${NAM}.tif
    #Faster tools, but not supporting zstd:
    #otbcli_BandMath -il $1 ~/cal/geoid_frm_${NAM}.tif -out $DIR/${NAM}_zmae.tif -exp "im1 - im2" 
    #image_calc -c "var_0 - var_1" $1 ~/cal/geoid_frm_${NAM}.tif -o $DIR/${NAM}_zmae.tif -d float32
}

geo2ell_isn93()
{
    NAM=$(basename "$1" | sed 's/.\{4\}$//')
    DIR=$(dirname "$1")
    gdalwarp -overwrite -r cubic -te $(get_georef $1) -tr $(get_px $1) $(get_px $1) \
        -t_srs "$(get_proj $1)" $lzwparam -of GTiff $geoid93 ~/cal/geoid_frm_${NAM}.tif
    gdal_calc.py --overwrite -A $1 -B ~/cal/geoid_frm_${NAM}.tif \
        --outfile $DIR/${NAM}_zmae.tif --calc="A+B" $demzstdpy --type Float32
    rm ~/cal/geoid_frm_${NAM}.tif
}

ell2geo_isn93()
{
    NAM=$(basename "$1" | sed 's/.\{4\}$//')
    DIR=$(dirname "$1")
    gdalwarp -overwrite -r cubic -te $(get_georef $1) -tr $(get_px $1) $(get_px $1) \
        -t_srs "$(get_proj $1)" $lzwparam -of GTiff $geoid93 ~/cal/geoid_frm_${NAM}.tif
    gdal_calc.py --overwrite -A $1 -B ~/cal/geoid_frm_${NAM}.tif \
        --outfile $DIR/${NAM}_zmasl.tif --calc="A-B" $demzstdpy --type Float32
    rm ~/cal/geoid_frm_${NAM}.tif
    #Faster tools, but not supporting zstd:
    #otbcli_BandMath -il $1 ~/cal/geoid_frm_${NAM}.tif -out $DIR/${NAM}_zmae.tif -exp "im1 - im2" 
    #image_calc -c "var_0 - var_1" $1 ~/cal/geoid_frm_${NAM}.tif -o $DIR/${NAM}_zmae.tif -d float32
}

apply_shiftXYZ()
{
    NAM=$(basename "$1" | sed 's/.\{4\}$//')
    DIR=$(dirname "$1")
    
    x_rou=$(printf "%.3f" $2)
    y_rou=$(printf "%.3f" $3)
    z_rou=$(printf "%.3f" $4)
    
    ULLR=$(get_georef $1 | awk -v dX=$2 -v dY=$3 '{ printf "%.3f %.3f %.3f %.3f", $1+dX, $4+dY, $3+dX, $2+dY}')
    gdal_translate -of VRT -a_ullr $ULLR $1 -a_srs "$(get_proj $1)" ~/cal/${NAM}_sftXY.vrt
    image_calc -c "var_0+$4" --tile-size 512,512 -d float32 ~/cal/${NAM}_sftXY.vrt -o $DIR/${NAM}_x${x_rou}_y${y_rou}_z${z_rou}.tif
    rm ~/cal/${NAM}_sftXY.vrt
}

apply_shiftXYortho()
{
    NAM=$(basename "$1" | sed 's/.\{4\}$//')
    DIR=$(dirname "$1")
    
    x_rou=$(printf "%.3f" $2)
    y_rou=$(printf "%.3f" $3)
    
    ULLR=$(get_georef $1 | awk -v dX=$2 -v dY=$3 '{ printf "%.3f %.3f %.3f %.3f", $1+dX, $4+dY, $3+dX, $2+dY}')
    gdal_translate -of VRT -a_ullr $ULLR $1 -a_srs "$(get_proj $1)" ${NAM}_sftXY.vrt
}

get_extend()
{
     
    ul_lon=`more $1 | grep "<LON>" | awk -F">" '{print $2}'| awk -F"<" '{print $1}' | awk 'NR==1{print $1; exit}'`
    ul_lat=`more $1 | grep "<LAT>" | awk -F">" '{print $2}'| awk -F"<" '{print $1}' | awk 'NR==1{print $1; exit}'`
    
    ur_lon=`more $1 | grep "<LON>" | awk -F">" '{print $2}'| awk -F"<" '{print $1}' | awk 'NR==2{print $1; exit}'`
    ur_lat=`more $1 | grep "<LAT>" | awk -F">" '{print $2}'| awk -F"<" '{print $1}' | awk 'NR==2{print $1; exit}'`
    
    lr_lon=`more $1 | grep "<LON>" | awk -F">" '{print $2}'| awk -F"<" '{print $1}' | awk 'NR==3{print $1; exit}'`
    lr_lat=`more $1 | grep "<LAT>" | awk -F">" '{print $2}'| awk -F"<" '{print $1}' | awk 'NR==3{print $1; exit}'`
    
    ll_lon=`more $1 | grep "<LON>" | awk -F">" '{print $2}'| awk -F"<" '{print $1}' | awk 'NR==4{print $1; exit}'`
    ll_lat=`more $1 | grep "<LAT>" | awk -F">" '{print $2}'| awk -F"<" '{print $1}' | awk 'NR==4{print $1; exit}'`
    
          
    min_lon="$(min_number $ul_lon $ur_lon $lr_lon $ll_lon)"
    max_lon="$(max_number $ul_lon $ur_lon $lr_lon $ll_lon)"
    min_lat="$(min_number $ul_lat $ur_lat $lr_lat $ll_lat)"
    max_lat="$(max_number $ul_lat $ur_lat $lr_lat $ll_lat)"
    
    bounding_box="${min_lon} ${min_lat} ${max_lon} ${max_lat}" 
    echo $bounding_box
}

min_number() {
    printf "%s\n" "$@" | sort -g | head -n1
}

max_number() {
   
    printf "%s\n" "$@" | sort -g | tail -n1
}


