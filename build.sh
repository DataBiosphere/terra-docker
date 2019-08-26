#!/bin/bash
# Run `gcloud auth configure-docker --quiet` before running this script
# Example: ./build.sh terra-jupyter-base

IMAGE_DIR=$1
VERSION=$(cat $IMAGE_DIR/VERSION)

TAG_NAME=$(git log --pretty=format:'%h' -n 1)
docker image build ./$IMAGE_DIR --tag us.gcr.io/broad-dsp-gcr-public/$IMAGE_DIR:$TAG_NAME --tag us.gcr.io/broad-dsp-gcr-public/$IMAGE_DIR:$VERSION \
    && docker push us.gcr.io/broad-dsp-gcr-public/$IMAGE_DIR:$TAG_NAME \
    && docker push us.gcr.io/broad-dsp-gcr-public/$IMAGE_DIR:$VERSION
