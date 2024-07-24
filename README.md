# PGO

The Pléiades Glacier Observatory is an initiative by the French Space Agency (CNES) and the Laboratoire d'Etudes en Géophysique et Océanographie Spatiales (LEGOS) to facilitate access to high resolution data from Pléiades satellites.
The script below generate DEMs at 20 m and 2 m using the Ames Stereo Pipeline (ASP). It also provide ortho-images at 2 m for multispectral bands and 0.5 m for the panchromatic band.
To ensure a good consistency of the PGO database, the DEMs are coregistered in a second step to the Copernicus GLO-30 DEM using the implementation by D. Shean (https://zenodo.org/records/7730376) of the Nuth and Kääb algorithm (2011).


## Downloads
For the script to work properly, the following tools must be downloaded: 
 - Ames Stereo Pipeline (ASP) tool (https://ti.arc.nasa.gov/tech/asr/groups/intelligent-robotics/ngt/stereo/) for the photogrammetric process ;
 - Orfeo Tool Box (OTB) (https://www.orfeo-toolbox.org/) for image manipulation ;
 - Demcoreg (https://zenodo.org/records/7730376) for co-registration of rasters.

## Installation of anaconda (used for coregistration in step 2)

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
Open the DEM_calculation.sh file and fill in the paths of ASP and  OTB (section "Path to dependencies"). Add also the path of the folder containing the images (ex: ./2021-04-03_SouthOrkney_ANT on the example below) and the path to GLO-30 DEM or another reference DEM (section "Parameters").<br/>

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
DEM_calculation.sh
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
Open the DEM_coregistration.sh file and fill in the paths of Anaconda bin and OTB and demcoreg folder (Section "Path to dependencies"). Add also the diffenrents path in "Parameters" section. <br/>

2. Run the script 
```
coregistration_DEM.sh
```
At this step a new folder is created (original) with the original DEMs and ortho-images before coregistration. New DEMs and orthos have "shifted" as a prefix. 

## Step 3 : Elevation difference biais corrections

1. Stand alone python file<br/>
After installing xDEM (https://xdem.readthedocs.io/en/stable/how_to_install.html), fill in the parameters section with your configuration. The processing can be quite consuming for large data with small spatial resolution. At the end of the script a figure is saved with some statistics<br/>






