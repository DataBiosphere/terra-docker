# terra-jupyter-hail image

This repo contains the terra-jupyter-hail image that is compatible with notebook service in [Terra]("https://app.terra.bio/") called Leonardo. For example, use `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-hail:{version}` in Terra.

This image expects to be launched on a Google Cloud Dataproc Terra rutime.

## Image contents

The terra-jupyter-hail image extends the [terra-jupyter-python](../terra-jupyter-python/README.md) by including the following:

- Hail
- Spark configs which get mounted in from Dataproc-managed VMs

To see the complete contents of this image please see the [Dockerfile](./Dockerfile).

## Selecting prior versions of this image

To select an older version this image, you can search the [CHANGELOG.md](./CHANGELOG.md) for a specific package version you need.

Once you find an image version that you want, simply copy and paste the image url from the changelog into the corresponding custom docker field in the Terra notebook runtime widget. 
