#!/bin/bash
# Run `gcloud auth configure-docker --quiet` before running this script
# Example: ./build_all.sh

# Create the ordered list of images to build
# 1- terra-core
# 2- terra-app
# 3- terra-base
# 4- terra-jupyter-base
# 5- terra-jupyter-python
# 6- terra-jupyter-r
# 7- terra-jupyter-gatk
# 8- terra-jupyter-hail
# 9- terra-jupyter-bioconductor
images=("terra-core" "terra-app" "terra-base" "terra-jupyter-base" "terra-jupyter-python" "terra-jupyter-r" "terra-jupyter-gatk" "terra-jupyter-hail" "terra-jupyter-bioconductor")

# Loop over each image to build in the correct order
for image in "${images[@]}"; do
  # Call build.sh with the image to build
  echo "Building and publishing the following image to GCR: $image"
  ./build.sh $image true
done

# Once all images have been built, generate and push the 'terra-docker-versions-new' doc
python scripts/generate_version_docs.py
