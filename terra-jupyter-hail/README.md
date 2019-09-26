# terra-jupyter-hail image

This image DOES NOT work properly yet. Use `us.gcr.io/broad-dsp-gcr-public/leonardo-jupyter:prod` instead if you'd like to use hail on Terra.
This repo contains the terra-jupyter-hail image that is compatible with notebook service in [Terra]("https://app.terra.bio/") called Leonardo. For example, use `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-hail:{version}` in terra.

## Image contents

The terra-jupyter-r extends the [terra-jupyter-base](../terra-jupyter-base/README.md) by including the following:

- Hail
- Spark

To see the complete contents of this image please see the [Dockerfile](./Dockerfile).

## Selecting prior versions of this image

To select an older version this image, you can search the [CHANGELOG.md](./CHANGELOG.md) for a specific package version you need.

Once you find an image version that you want, simply copy and paste the image url from the changelog into the corresponding custom docker field in the Terra notebook runtime widget. 
