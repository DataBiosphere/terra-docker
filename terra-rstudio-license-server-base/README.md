# terra-rstudio-license-server image

This repo contains the terra-rstudio-base image that is compatible with notebook service in [Terra]("https://app.terra.bio/") called Leonardo. For example, use `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-base:{version}` in terra.

## Image contents

The terra-jupyter-license-server extends the [Ubuntu base image]("https://github.com/tianon/docker-brew-ubuntu-core/blob/9db8c72dd02e8f9fd5dba82ff9266174b088e2e6/bionic/Dockerfile") by including the following:

- OS prerequisites
- google-cloud-sdk
- RStudio license server

To see the complete contents of this image please see the [Dockerfile](./Dockerfile).

## Selecting prior versions of this image

To select an older version this image, you can search the [CHANGELOG.md](./CHANGELOG.md) for a specific package version you need.

Once you find an image version that you want, simply copy and paste the image url from the changelog into the corresponding custom docker field in the Terra notebook runtime widget. 
