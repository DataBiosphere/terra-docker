# terra-jupyter-r image

This repo contains the terra-jupyter-r image that is compatible with notebook service in [Terra]("https://app.terra.bio/") called Leonardo. For example, use `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-r:{version}` in terra.

## Image contents

The terra-jupyter-r extends the [terra-jupyter-base](../terra-jupyter-base/README.md) by including the following:

- R 4.1.0

- CRAN and Bioc 3.13 package system dependencies

To see the complete contents of this image please see the [Dockerfile](./Dockerfile).

## Selecting prior versions of this image

To select an older version this image, you can search the [CHANGELOG.md](./CHANGELOG.md) for a specific package version you need.

Once you find an image version that you want, simply copy and paste the image url from the changelog into the corresponding custom docker field in the Terra notebook runtime widget. 
