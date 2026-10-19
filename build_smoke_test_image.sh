#!/bin/bash
# Perform a local build of an image for smoke-testing purposes. Also build its tree of base images, when missing.
#
# Example: ./build_smoke_test_image.sh terra-jupyter-base
#
# Current working directory must be the directory in which this script resides (one level above all the Dockerfiles).
# It walks down each relevant image directory, making changes to the FROM statements,
# as needed, to refer to locally built base images.

set -o errexit
set -o pipefail
set -o nounset
set -o xtrace 

build_smoke_test_image() {
  local IMAGE_TYPE=${1:-"terra-jupyter-base"}
  pushd ${IMAGE_TYPE}
  # The image is the first FROM argument that is not an option such as --platform=${BASE_PLATFORM}
  local BASE_IMAGES=$( awk '/^FROM/ { for (i=2; i<=NF; i++) if ($i !~ /^--/) { print $i; break } }' Dockerfile )

  local BASE_IMAGE
  for BASE_IMAGE in ${BASE_IMAGES}; do
    local PULL_RESULT=$( docker pull -q $BASE_IMAGE )

    if [[ -n "${PULL_RESULT}" ]]; then
      echo "${BASE_IMAGE} exists"
    else
      echo "${BASE_IMAGE} does not exist, building it locally"
      local BASE_IMAGE_TYPE=$( echo ${BASE_IMAGE} | cut -d '/' -f 3 | cut -d ':' -f 1)
      local LOCAL_BASE_IMAGE=${BASE_IMAGE_TYPE}:smoke-test
      # Call this function recursively to build base images for however many levels down we need to go.
      popd
      build_smoke_test_image ${BASE_IMAGE_TYPE}
      pushd ${IMAGE_TYPE}
      # Edit our local copy of the Dockerfile to use the locally built base image.
      sed -i "s;${BASE_IMAGE};${LOCAL_BASE_IMAGE};g" Dockerfile
    fi
  done

  docker build . --file Dockerfile --tag ${IMAGE_TYPE}:smoke-test
  popd
}

# Log available disk space prior to building image
df -kh

build_smoke_test_image "${1:-}"
