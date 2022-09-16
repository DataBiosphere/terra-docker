# terra-jupyter-minimal-base image

This repo contains the terra-jupyter-minimal-base image that is compatible with 
notebook service in [Terra]("https://app.terra.bio/") called Leonardo.

## Image contents

`terra-jupyter-minimal-base` extends an Ubuntu 20.04 base image with the minimum 
requirements necessary to set up Jupyter and provide compatibility with Leonardo.

- OS prerequisites
- google-cloud-cli
- Python 3.7
- Miniconda
- Jupyter
- Leonardo customizations/extensions
- Terra python client library ([FISS](https://github.com/broadinstitute/fiss))
- Full list of python packages is available [here](requirements.txt) and 
  [here](requirements_gcc.txt)

To see the complete contents of this image please see the [Dockerfile](./Dockerfile).

## Notes

- Currently, the environment variable `WORKSPACE_BUCKET` is not getting set 
  correctly when this image is used to create a Cloud Environment in Terra
  - The value is `'.'`
  - This will be fixed in future versions
  - For now, it's recommended to avoid using this environment variable

## Selecting prior versions of this image

To select an older version this image, you can search the [CHANGELOG.md](./CHANGELOG.md) 
for a specific package version you need.

Once you find an image version that you want, simply copy and paste the image 
url from the changelog into the corresponding custom docker field in the Terra 
notebook runtime widget. 
