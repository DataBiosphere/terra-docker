#!/bin/bash
# Run `gcloud auth configure-docker --quiet` before running this script
# Example: ./build_all.sh

# Create the ordered list of images to build
# 1- terra-jupyter-base
# 2- terra-jupyter-base
# 3- terra-jupyter-python
# 4- terra-jupyter-r
# 5- terra-jupyter-gatk
# 6- terra-jupyter-hail
# 7- terra-jupyter-aou
# 8- terra-jupyter-bioconductor
# 9- terra-rstudio-aou
# 10- wondershaper
images=("terra-base", "terra-jupyter-base" "terra-jupyter-python" "terra-jupyter-r" "terra-jupyter-gatk" "terra-jupyter-hail" "terra-jupyter-aou" "terra-jupyter-bioconductor" "terra-rstudio-aou" "wondershaper")

# Loop over each image to build in the correct order
for image in "${images[@]}"; do
  # Call build.sh with the image to build
  echo "Building and publishing the following image to GCR: $image"
  ./build.sh $image true
done

# Once all images have been built, generate and push the 'terra-docker-versions-new' doc
python scripts/generate_version_docs.py