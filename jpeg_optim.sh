#!/bin/bash
# chemin vers le répertoire d'assets
ASSETS_DIR="./assets"

# parcourir les fichiers
find $ASSETS_DIR -type f -name "*.jpg" | while read -r file
do
    echo "Optimisation de $file..."
   
     # utilisation de jpegoptim pour l'optimisation
    jpegoptim -m80 --strip-all "$file"
   
    # ou utilisation de imagemagick pour l'optimisation
    # convert "$file" -sampling-factor 4:2:0 -strip -quality 85 -interlace JPEG -colorspace RGB "$file"
done

echo "Optimisation terminée."