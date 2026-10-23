#!/bin/bash
# Run `gcloud auth configure-docker --quiet` before running this script
# Example: ./build.sh terra-jupyter-base
# Example: ./build.sh terra-jupyter-base true
# Example: KEEP_LOCAL_IMAGE=true ./build.sh terra-jupyter-base true
#
# Optional environment variables:
#   KEEP_LOCAL_IMAGE  true keeps the pulled image in the local docker store after the build
set -e -x
set -o pipefail

IMAGE_DIR=$1
SKIP_GCP_AUTH=${2:-${SKIP_GCP_AUTH:-}}
KEEP_LOCAL_IMAGE=${KEEP_LOCAL_IMAGE:-false}
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

if [[ "${SKIP_GCP_AUTH}" != "true" ]]; then
  # Docker silently creates the mount source as a directory when it does not
  # exist, which makes vault fail with "is a directory" instead of anything
  # useful. Check up front so the error names the real problem.
  if [[ ! -f "$VAULT_LOCATION" ]]; then
      echo "No vault token file at $VAULT_LOCATION (it must be a file, not a directory)."
      echo "Create one with:"
      echo "  docker run -it --rm -v \$HOME:/root -e VAULT_ADDR=https://clotho.broadinstitute.org:8200 \\"
      echo "    broadinstitute/dsde-toolbox:latest vault login -method=github"
      echo "Or re-run with SKIP_GCP_AUTH=true to use your existing gcloud credentials."
      #unreserved exit code for checking in jenkins
      exit 16
  fi

  # will fail if you are not gcloud authed as dspci-wb-gcr-service-account or secret/dsde/firecloud/common/image-build-account.json
  # the below works locally but not on jenkins for some reason, using a different account until a resolution is found
  # docker run --rm  -v $VAULT_LOCATION:/root/.vault-token:ro broadinstitute/dsde-toolbox:latest vault read --format=json secret/dsde/dsp-techops/common/dspci-wb-gcr-service-account.json | jq .data > dspci-wb-gcr-service-account.json
  # gcloud auth activate-service-account --key-file=dspci-wb-gcr-service-account.json
  docker run --rm  -v $VAULT_LOCATION:/root/.vault-token:ro broadinstitute/dsde-toolbox:latest vault read --format=json secret/dsde/firecloud/common/image-build-account.json | jq .data > image-build-account.json

  # jq happily writes an empty file when the vault read produced nothing, which
  # surfaces later as a confusing "Could not read json file" from gcloud.
  if [[ ! -s image-build-account.json ]]; then
      echo "vault read produced an empty image-build-account.json; see the error above."
      #unreserved exit code for checking in jenkins
      exit 16
  fi

  gcloud auth activate-service-account --key-file=image-build-account.json
  gcloud auth configure-docker --quiet
fi


# Build and push in a single buildx step.
#
# Leonardo's registry client only accepts Docker schema 2 media types, so an OCI
# manifest or index makes its image auto-detection fail with MANIFEST_UNKNOWN. A
# plain `docker build && docker push` emits an OCI index whenever the daemon uses
# the containerd image store, which is the default in recent Docker versions.
#   --platform      pins the target arch; otherwise the manifest records the
#                   builder host's arch even when the FROM line is pinned to amd64
#   --provenance    attestations are published as an extra manifest, which turns
#   --sbom          the push into an index even for a single-platform image
#   oci-mediatypes  false forces application/vnd.docker.distribution.manifest.v2+json
docker buildx build ./$IMAGE_DIR \
  --platform linux/amd64 \
  --provenance=false \
  --sbom=false \
  --output type=image,oci-mediatypes=false,push=true \
  --tag $GCR_IMAGE_REPO/$IMAGE_DIR:$TAG_NAME \
  --tag $GCR_IMAGE_REPO/$IMAGE_DIR:$VERSION \
  --tag $GCR_IMAGE_REPO/$IMAGE_DIR:latest

# Fail the build rather than publishing something Leonardo cannot read.
MANIFEST_TYPE=$(docker buildx imagetools inspect --raw $GCR_IMAGE_REPO/$IMAGE_DIR:$VERSION | jq -r '.mediaType')
if [ "$MANIFEST_TYPE" != "application/vnd.docker.distribution.manifest.v2+json" ]; then
    echo "Pushed manifest is $MANIFEST_TYPE, expected application/vnd.docker.distribution.manifest.v2+json."
    echo "Leonardo will not be able to auto-detect this image."
    #unreserved exit code for checking in jenkins
    exit 15
fi

# buildx pushed straight to the registry without loading the image into the local
# store, so pull it back for the doc-generation container below.
docker pull $GCR_IMAGE_REPO/$IMAGE_DIR:$VERSION

docker kill $IMAGE_DIR || true
docker rm -f $IMAGE_DIR || true
docker run --rm -itd -u root -e PIP_USER=false --entrypoint='/bin/bash' --name $IMAGE_DIR $GCR_IMAGE_REPO/$IMAGE_DIR:$VERSION

gcloud auth list
python3 scripts/generate_package_docs.py "$IMAGE_DIR"

docker kill $IMAGE_DIR || true
docker rm -f $IMAGE_DIR || true
if [[ "${KEEP_LOCAL_IMAGE}" != "true" ]]; then
  docker image rm -f $GCR_IMAGE_REPO/$IMAGE_DIR:$VERSION
  docker image rm -f $GCR_IMAGE_REPO/$IMAGE_DIR:$TAG_NAME
fi

echo "Successfully completed build script for $IMAGE_DIR"
