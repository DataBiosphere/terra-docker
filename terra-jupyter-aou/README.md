# terra-jupyter-aou image

This repo contains the terra-jupyter-aou image that is compatible with notebook service in [Terra]("https://app.terra.bio/") called Leonardo. For example, use `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-aou:{version}` in terra.

This image is intended to support usage in the [All of Us Workbench](https://github.com/all-of-us/workbench), which depends on Leonardo.

## Image contents

The terra-jupyter-aou extends the [terra-jupyter-python](../terra-jupyter-python/README.md) and [terra-jupyter-r](../terra-jupyter-r/README.md) by including the following:

- Open JDK
- Libraries to support All of Us anlaysis use cases

To see the complete contents of this image please see the [Dockerfile](./Dockerfile).

## Selecting prior versions of this image

To select an older version this image, you can search the [CHANGELOG.md](./CHANGELOG.md) for a specific package version you need.

Once you find an image version that you want, simply copy and paste the image url from the changelog into the corresponding custom docker field in the Terra notebook runtime widget. 
