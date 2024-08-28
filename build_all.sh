#!/bin/bash
# Run `gcloud auth configure-docker --quiet` before running this script
# Example: ./build_all.sh

# Create the ordered list of images to build
# 1- terra-jupyter-base
# 2- terra-jupyter-python
# 3- terra-jupyter-r
# 4- terra-jupyter-gatk
# 5- terra-jupyter-hail
# 6- terra-jupyter-aou
# 7- terra-jupyter-bioconductor
# 8- terra-rstudio-aou
# 9- wondershaper
images=(terra-jupyter-base terra-jupyter-python terra-jupyter-r terra-jupyter-gatk terra-jupyter-hail terra-jupyter-aou terra-jupyter-bioconductor terra-rstudio-aou wondershaper)

# Loop over each image to build in the correct order
for image in images; do
  # Call build.sh with the image to build
  echo "Building and publishing the following image to GCR: $image"
  ./build.sh $image true
done

# Once all images have been built, generate and push the 'terra-docker-versions-new' doc
python scripts/generate_version_docs.py