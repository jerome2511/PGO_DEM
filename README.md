# PGO

The Pléiades Glacier Observatory (PGO) is an initiative by the French Space Agency (CNES) and the Laboratory in Geophysics and Space Oceanography (LEGOS) to facilitate access to Pléiades satellite stereo-imagery and digital elevation models (DEMs) for glaciologists.

The PGO program covers 142 sites spread all over the globe with targeted acquisitions generally at the end of the melt season. The product consists of digital elevation models (DEMs) at 2 m and 20 m ground sampling distance together with 0.5 m (panchromatic) and 2 m (multispectral) ortho-images. For the photogrammetric process, the Ames Stereo Pipeline [Beyer et al., Earth and Space Science, 2018] is used with processing parameters from [Marti et al., TC, 2016] for block matching -BM- and from [Deschamps-Berger et al. TC 2020] for semi global matching -SGM. To ensure a good consistency of the PGO database, the DEMs are coregistered in a second step to the Copernicus GLO-30 DEM using the implementation by D. Shean [Shean et al., ISPRS J. Photogramm. Remote Sens, 2016] of the algorithm by Nuth and Kääb (2011).

The first PGO campaigns took place in 2016 in the north Hemisphere and early 2017 in the south Hemisphere. Since 2021 in the northern Hemisphere and 2022 in the southern Hemisphere, the PGO has entered in revisit mode. Each site will be imaged again, allowing the production of elevation difference maps for each glacier every five years.

More details at https://www.legos.omp.eu/pgo/


## Downloads
For the script to work properly, the following tools must be downloaded: 
 - Ames Stereo Pipeline (ASP) tool (https://ti.arc.nasa.gov/tech/asr/groups/intelligent-robotics/ngt/stereo/)  for the photogrammetric process ;
 - Orfeo Tool Box (OTB) (https://www.orfeo-toolbox.org/) for image manipulation ;
 - Demcoreg tool from David Shean (https://github.com/jerome2511/PGO_DEM/blob/main/README.md) for co-registration of rasters.

## Installation of anaconda

1. Install miniconda<br/>
After downloading the latest version of miniconda (https://docs.conda.io/en/latest/miniconda.html), run the installation file.
```
chmod +x Miniconda3-latest-Linux-x86_64.sh
Miniconda3-latest-Linux-x86_64.sh
```
2. Installing dependencies
```
conda install gdal
pip install pygeotools
pip install demcoreg
pip install imview
```

## Step 1 : DEM and ortho-image calculation
1. Parameter<br/>
Open the DEM_calculation.sh file and fill in the paths of ASP and  OTB. Add also the path of the folder containing the images (ex: ./2021-04-03_SouthOrkney_ANT on the example below) and the path to GLO-30 DEM (or any DEM for map projection, same DEM for coregistration).<br/>

```
.
├── ...
├── 2021-04-03_12226435_SouthOrkney_ANT   # Repertory wich is linked to the script
│   ├── IMG_PHR1B_P_001          # Repertory with first panchromatic image files
│   ├── IMG_PHR1B_P_002          # Repertory with second panchromatic image files
│   ├── IMG_PHR1B_MS_003         # Repertory with first multispectral image files
│   └── IMG_PHR1B_MS_004         # Repertory with second multispectral image files
└── ...
```

2. Run the script 
```
cd PathToScript/PGO_DEM-master/
stereo_hal_calcul_dem.sh
```
At this step a new folder is created with the name of the correlation algorithm used (BM or SGM) containing the associated DEMs and orthoimages. 

```
.
├── ...
├── 2021-04-03_12226435_SouthOrkney_ANT   
│   ├── IMG_PHR1B_P_001          
│   ├── IMG_PHR1B_P_002          
│   ├── IMG_PHR1B_MS_003         
│   ├── IMG_PHR1B_MS_004         
│   └── BM   
│       ├── 2021-04-03_12226435_SouthOrkney_ANT_DEM_BM_2m.tif  
│       ├── 2021-04-03_12226435_SouthOrkney_ANT_DEM_BM_20m.tif   
│       ├── 2021-04-03_12226435_SouthOrkney_ANT_PAN_BM_0.5m.tif  
│       └── 2021-04-03_12226435_SouthOrkney_ANT_MS_BM_2m.tif 
└── ...
```

## Step 2 : Coregistration

1. Parameter<br/>
Open the DEM_coregistration.sh file and fill in the path of Anaconda bin and demcoreg folder. Add also the differents path in paramters section. <br/>

2. Run the script 
```
DEM_coregistration.sh
```
At this step, a new folder is created (original) with the original DEMs and ortho-images before coregistration. New DEMs and orthos have "shifted" as a prefix. 

## To go further

Beyer et al.: The Ames Stereo Pipeline: NASA's Open Source Software for Deriving and Processing Terrain Data, Earth and Space Science, 5(9), 537–548,doi:10.1029/2018EA000409, 2018.

Shean et al., An automated, open-source pipeline for mass production of digital elevation models (DEMs) from very high-resolution commercial stereo satellite imagery, ISPRS J. Photogramm. Remote Sens, 116, 101-117, doi: 10.1016/j.isprsjprs.2016.03.012, 2016.

Deschamps-Berger et al.: Snow depth mapping from stereo satellite imagery in mountainous terrain: evaluation using airborne laser-scanning data, The Cryosphere, 14(9),2925–2940, https://doi.org/10.5194/tc-14-2925-2020, 2020.

Marti et al.: Mapping snow depth in open alpine terrain from stereo satellite imagery, The Cryosphere, 10(4), 1361–1380, doi:10.5194/tc-10-1361-2016, 2016


