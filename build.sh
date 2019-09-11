#!/bin/bash
# Run `gcloud auth configure-docker --quiet` before running this script
# Example: ./build.sh terra-jupyter-base

IMAGE_DIR=$1
VERSION=$(cat $IMAGE_DIR/VERSION)

TAG_NAME=$(git log --pretty=format:'%h' -n 1)
REPO="us.gcr.io/broad-dsp-gcr-public"

IMAGE_EXISTS=$(gcloud container images list-tags $REPO/$IMAGE_DIR | grep $VERSION)

exit 1

if [ -z "$IMAGE_EXISTS" ]
then 
    echo "An image for this version not exist. Proceeding with build"
else 
    echo "An image for the version you are trying to build already exists. Ensure you have updated the VERSION file."
    exit 1
fi

docker image build ./$IMAGE_DIR --tag $REPO/$IMAGE_DIR:$TAG_NAME --tag $REPO/$IMAGE_DIR:$VERSION \
    && docker push $REPO/$IMAGE_DIR:$TAG_NAME \
    && docker push $REPO/$IMAGE_DIR:$VERSION

docker rm $REPO/$IMAGE_DIR

echo "Successfully completed build script for $IMAGE_DIR"