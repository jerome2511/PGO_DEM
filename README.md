# PGO_DEM

Script permettant de calculer un modèle numérique de surface (MNS) à partir d'un couple stéréoscopique Pléiades. Par defaut, deux MNS aux résolutions spatiale de 20 m et 2 M sont produits ainsi q'une orthoimage panchromatique à 0.5 m et une orthoimage multispectrale (R-V-B-IR) à 2 m.
Ces données sont coregistré selon un MNT de référence (ex : Global Copernicus DEM) par la méthode développée par Nuth and Kaab. 


## Installation
Le bon fonctionnement du script nécessite l'instalation des dépendences suivantes : 
 - The Ames Stereo Pipeline (https://ti.arc.nasa.gov/tech/asr/groups/intelligent-robotics/ngt/stereo/) for the photogrammetric steps.
 - Orfeo Tool Box (https://www.orfeo-toolbox.org/) for image manipulation.

## How to use
