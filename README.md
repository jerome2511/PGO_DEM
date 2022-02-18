# PGO_DEM

Script permettant de calculer un modèle numérique de surface (MNS) à partir d'un couple stéréoscopique Pléiades. Par defaut, deux MNS aux résolutions spatiale de 20 m et 2 M sont produits ainsi q'une orthoimage panchromatique à 0.5 m et une orthoimage multispectrale (R-V-B-IR) à 2 m.
Ces données sont coregistré selon un MNT de référence (ex : Global Copernicus DEM) par la méthode développée par Nuth and Kaab. 


## Installation
Le bon fonctionnement du script nécessite l'instalation des dépendences suivantes : 
 - L'outil Ames Stereo Pipeline (https://ti.arc.nasa.gov/tech/asr/groups/intelligent-robotics/ngt/stereo/) pour le processus photogrammétrique.
 - Orfeo Tool Box (https://www.orfeo-toolbox.org/) pour la manipulation des images.
 - Demcoreg (https://github.com/dshean/demcoreg) pour la coregistration.

## Fonctionnement

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
2. Chemin des dépendances
Ouvir le fichier link_dependencies.sh du dossier dépendances et renseigner les chemins des dépendances précedements installées (cf exemple en fichier link_dependencies_exemple.sh)
