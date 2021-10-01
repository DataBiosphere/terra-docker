#!/bin/bash
# Run `gcloud auth configure-docker --quiet` before running this script
# Example: ./build.sh terra-jupyter-base
set -e -x

IMAGE_DIR=$1
VERSION=$(cat config/conf.json | jq -r ".image_data | .[] | select(.name == \"$IMAGE_DIR\") | .version")

TAG_NAME=$(git log --pretty=format:'%h' -n 1)
GCR_IMAGE_REPO=$(cat config/conf.json | jq -r .gcr_image_repo)

#below is a regex to match strictly on $VERSION, not any tags which have a substring of $VERSION
IMAGE_EXISTS=$(gcloud container images list-tags  --filter="TAGS~^$VERSION$" $GCR_IMAGE_REPO/$IMAGE_DIR)

if [ -z "$IMAGE_EXISTS" ]; then
    echo "An image for this version does not exist. Proceeding with build"
else
    echo "An image for the version you are trying to build already exists. Ensure you have updated the VERSION file."
    #unreserved exit code for checking in jenkins
    exit 14
fi

VAULT_LOCATION=~/.vault-token
if [[ $VAULT_LOCATION == *"jenkins"* ]]; then
    VAULT_LOCATION="/etc/vault-token-dsde"
fi

# will fail if you are not gcloud authed as dspci-wb-gcr-service-account or secret/dsde/firecloud/common/image-build-account.json
# the below works locally but not on jenkins for some reason, using a different account until a resolution is found
# docker run --rm  -v $VAULT_LOCATION:/root/.vault-token:ro broadinstitute/dsde-toolbox:latest vault read --format=json secret/dsde/dsp-techops/common/dspci-wb-gcr-service-account.json | jq .data > dspci-wb-gcr-service-account.json
# gcloud auth activate-service-account --key-file=dspci-wb-gcr-service-account.json
docker run --rm  -v $VAULT_LOCATION:/root/.vault-token:ro broadinstitute/dsde-toolbox:latest vault read --format=json secret/dsde/firecloud/common/image-build-account.json | jq .data > image-build-account.json
gcloud auth activate-service-account --key-file=image-build-account.json
gcloud auth configure-docker --quiet

docker image build ./$IMAGE_DIR --tag $GCR_IMAGE_REPO/$IMAGE_DIR:$TAG_NAME --tag $GCR_IMAGE_REPO/$IMAGE_DIR:$VERSION

docker push $GCR_IMAGE_REPO/$IMAGE_DIR:$TAG_NAME
docker push $GCR_IMAGE_REPO/$IMAGE_DIR:$VERSION

if [[ $IMAGE_DIR = "terra-jupyter-aou" ]]; then
  docker tag $GCR_IMAGE_REPO/$IMAGE_DIR:$TAG_NAME broadinstitute/$IMAGE_DIR:$TAG_NAME
  docker tag $GCR_IMAGE_REPO/$IMAGE_DIR:$VERSION broadinstitute/$IMAGE_DIR:$VERSION

  docker push broadinstitute/$IMAGE_DIR:$VERSION
  docker push broadinstitute/$IMAGE_DIR:$TAG_NAME
fi

docker kill $IMAGE_DIR || true
docker rm -f $IMAGE_DIR || true
docker run --rm -itd -u root -e PIP_USER=false --entrypoint='/bin/bash' --name $IMAGE_DIR $GCR_IMAGE_REPO/$IMAGE_DIR:$VERSION

gcloud auth list
python scripts/generate_package_docs.py "$IMAGE_DIR"

docker kill $IMAGE_DIR || true
docker rm -f $IMAGE_DIR || true
docker image rm -f $GCR_IMAGE_REPO/$IMAGE_DIR:$VERSION
docker image rm -f $GCR_IMAGE_REPO/$IMAGE_DIR:$TAG_NAME

echo "Successfully completed build script for $IMAGE_DIR"
