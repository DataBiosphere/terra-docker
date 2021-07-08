#!/bin/bash
# Perform a local build of an image.
#s
# Example: ./build_images terra-jupyter-python  
#
# Current working directory must be the directory in which this script resides (one level above all the Dockerfiles).
# It walks down each relevant image directory, making changes to the FROM statements,
# as needed, to refer to locally built base images.

set -o errexit
set -o pipefail
set -o nounset
set -o xtrace 

build_images() {
  local IMAGE_TYPE=$1
  pushd ${IMAGE_TYPE}
  local BASE_IMAGES=$( egrep '^FROM (\S+)' Dockerfile |tr -s ' ' | cut -d ' ' -f 2 )

  local BASE_IMAGEs
  for BASE_IMAGE in ${BASE_IMAGES}; do
    local PULL_RESULT=$( docker pull -q $BASE_IMAGE )

    if [[ -n "${PULL_RESULT}" ]]; then
      echo "${BASE_IMAGE} exists"
    else
      echo "${BASE_IMAGE} does not exist, building it locally"
      local BASE_IMAGE_TYPE=$( echo ${BASE_IMAGE} | cut -d '/' -f 3 | cut -d ':' -f 1)
      local TAG=$(cat ../config/conf.json | jq -r ".image_data | .[] | select(.name == \"$BASE_IMAGE_TYPE\") | .version")
      local LOCAL_BASE_IMAGE=${BASE_IMAGE_TYPE}:$TAG
      # docker push this

      # Call this function recursively to build base images for however many levels down we need to go.
      popd
      build_images ${BASE_IMAGE_TYPE}
      pushd ${IMAGE_TYPE}
    fi
  done

  docker build . --file Dockerfile --tag ${IMAGE_TYPE}:$(cat ../config/conf.json | jq -r ".image_data | .[] | select(.name == \"${IMAGE_TYPE}\") | .version")
  popd
}

build_images $1
