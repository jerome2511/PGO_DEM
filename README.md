# PGO_DEM

Script permettant de calculer un modèle numérique de surface (MNS) à partir d'un couple stéréoscopique Pléiades. Par defaut, deux MNS aux résolutions spatiale de 20 m et 2 M sont produits ainsi q'une orthoimage panchromatique à 0.5 m et une orthoimage multispectrale (R-V-B-IR) à 2 m.
Ces données sont coregistré selon un MNT de référence (ex : Global Copernicus DEM) par la méthode développée par Nuth and Kaab. 


## Téléchargements
Le bon fonctionnement du script nécessite le téléchargement des outils suivants : 
 - L'outil Ames Stereo Pipeline (https://ti.arc.nasa.gov/tech/asr/groups/intelligent-robotics/ngt/stereo/) pour le processus photogrammétrique.
 - Orfeo Tool Box (https://www.orfeo-toolbox.org/) pour la manipulation des images.

## Installation

1. Installer miniconda<br/>
Après avoir téléchargé la dernière version de miniconda (https://docs.conda.io/en/latest/miniconda.html), executer le fichier d'installation.
```
chmod +x Miniconda3-latest-Linux-x86_64.sh
Miniconda3-latest-Linux-x86_64.sh
```
2. Installer les dépendances
```
conda install gdal
pip install pygeotools
pip install demcoreg
pip install imview
```

## How to use
1. Chemin des paramètres<br/>
Ouvir le fichier settings.sh et y renseigner les chemins des dépendances précedements installées. Ajouter aussi le chemin du dossier contenant les images (ex : ./2021-04-03_SouthOrkney_ANT sur l'exemple ci-dessous).<br/>
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

Le nom des MNS crées seront donnés selon le nom du dossier regroupant les images panchromatiques et multispectrales. Ici : 2021-04-03_12226435_SouthOrkney_ANT_DEM_BM_2m.tif et 2021-04-03_12226435_SouthOrkney_ANT_DEM_BM_20m.tif pour les MNS.


2. Lancer le script 
```
DEM_coregistration.sh
```
Un nouveau dossier est alors crée au nom de l'algorithme de corrélation utilisé (BM ou SGM) contenant les MNS et ortho-images associées. 

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






