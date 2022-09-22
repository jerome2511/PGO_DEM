# PGO

The Pléiades Glacier Observatory is an initiative by the French Space Agency (CNES) and the Laboratoire d'Etudes en Géophysique et Océanographie Spatiales (LEGOS) to facilitate access to high resolution data from the Pléiades satellites.
The script below generate DEMs at 20 m and 2 m using the Ames Stereo Pipeline (ASP). It also provide ortho-images at 2 m for multispectral bands and 0.5 m for the panchromatic band.
To ensure a good consistency of the PGO database, the DEMs are coregistered in a second step to the Copernicus GLO-30 DEM using the implementation by D. Shean (https://github.com/dshean/demcoreg) of the algorithm by Nuth and Kääb (2011).


## Downloads
For the script to work properly, the following tools must be downloaded: 
 - Ames Stereo Pipeline (ASP) tool (https://ti.arc.nasa.gov/tech/asr/groups/intelligent-robotics/ngt/stereo/)  for the photogrammetric process.
 - Orfeo Tool Box (OTB) (https://www.orfeo-toolbox.org/) for image manipulation.

## Installation

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

## How to use
1. Parameter<br/>
Open the settings.sh file and fill in the paths of ASP, OTB and anaconda. Add also the path of the folder containing the images (ex: ./2021-04-03_SouthOrkney_ANT on the example below).<br/>
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

The name of the MNS created will be given according to the name of the folder regrouping the panchromatic and multispectral images. Here: 2021-04-03_12226435_SouthOrkney_ANT_DEM_BM_2m.tif and 2021-04-03_12226435_SouthOrkney_ANT_DEM_BM_20m.tif for the MNS.


2. Run the script 
```
stereo_coregistration.sh
```
At this step a new folder is created with the name of the correlation algorithm used (BM or SGM) containing the associated DSMs and orthoimages. 

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






