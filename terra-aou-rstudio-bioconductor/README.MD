# terra-rstudio-aou image

This repo contains the terra-rstudio-aou image that is compatible with notebook service in [Terra]("https://app.terra.bio/") called Leonardo. For example, use `us.gcr.io/broad-dsp-gcr-public/terra-rstudio-aou:{version}` in terra.

This image is intended to support usage in the [All of Us Workbench](https://github.com/all-of-us/workbench), which depends on Leonardo.

## Image contents

The terra-rstudio-aou extends the [Bioconductor Rstudio](https://github.com/Bioconductor/bioconductor_docker) by including the following:

- Welder for file syncing
- Wondershaper for network rate limiting

To see the complete contents of this image please see the [Dockerfile](./Dockerfile).

## Selecting prior versions of this image

To select an older version this image, you can search the [CHANGELOG.md](./CHANGELOG.md) for a specific package version you need.

Once you find an image version that you want, simply copy and paste the image url from the changelog into the corresponding custom docker field in the Terra notebook runtime widget.
