# terra-rstudio-aou image

This repo contains the terra-rstudio-aou image that is compatible with the notebook service in [Terra]("https://app.terra.bio/") called Leonardo. For example, use `us.gcr.io/broad-dsp-gcr-public/terra-rstudio-aou:{version}` in Terra.

This image is intended to support usage in the [All of Us Workbench](https://github.com/all-of-us/workbench).

## Image contents

The terra-rstudio-aou extends the [AnVIL Bioconductor image](https://github.com/anvilproject/anvil-docker) by including the following:

- Configuring `wondershaper` to limit network bandwidth.

To see the complete contents of this image please see the [Dockerfile](./Dockerfile).

## Selecting prior versions of this image

To select an older version this image, you can search the [CHANGELOG.md](./CHANGELOG.md) for a specific package version you need.

Once you find an image version that you want, copy and paste the image url from the changelog into the corresponding custom Docker field in the Terra notebook runtime widget.
