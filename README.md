# PGO_DEM

Script permettant de calculer un modèle numérique de surface (MNS) à partir d'un couple stéréoscopique Pléiades. Par defaut, deux MNS aux résolutions spatiale de 20 m et 2 M sont produits ainsi q'une orthoimage panchromatique à 0.5 m et une orthoimage multispectrale (R-V-B-IR) à 2 m.
Ces données sont coregistré selon un MNT de référence (ex : Global Copernicus DEM) par la méthode développée par Nuth and Kaab. 


## Téléchargements
Le bon fonctionnement du script nécessite le téléchargement des outils suivants : 
 - L'outil Ames Stereo Pipeline (https://ti.arc.nasa.gov/tech/asr/groups/intelligent-robotics/ngt/stereo/) pour le processus photogrammétrique.
 - Orfeo Tool Box (https://www.orfeo-toolbox.org/) pour la manipulation des images.

## Installation

1. Installer miniconda
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
3. Chemin des paramètres<br/>
Ouvir le fichier settings.sh du dossier settings et y renseigner les chemins des dépendances précedements installées. Ajouter aussi le chemin du dossier contenant les images (ex : ./2021-04-03_SouthOrkney_ANT sur l'exemple ci-dessous).<br/>
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


4. Lancer le script 
```
DEM_coregistration.sh
```
