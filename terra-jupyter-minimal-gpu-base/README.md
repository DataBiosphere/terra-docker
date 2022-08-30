# terra-jupyter-minimal-gpu-base image

This repo contains the terra-jupyter-minimal-gpu-base image that is compatible with 
notebook service in [Terra]("https://app.terra.bio/") called Leonardo.

## Image contents

`terra-jupyter-minimal-gpu-base` extends an image from Nvidia built on top of 
Ubuntu 20.04 called `nvcr.io/nvidia/cuda:11.3.1-base-ubuntu20.04`, which has CUDA and
Nvidia drivers installed. This image adds the minimum 
requirements necessary to set up Jupyter and provide compatibility with Leonardo.

- CUDA 11.3
- Nvidia driver version 465.19.01
- OS prerequisites
- google-cloud-cli
- Python 3.7
- Miniconda
- Jupyter
- Leonardo customizations/extensions
- Terra python client library ([FISS](https://github.com/broadinstitute/fiss))
- Full list of python packages is available [here](requirements.txt) and 
  [here](requirements_gcc.txt)

The philosophy here is minimalism, so that this image can be built upon. 
To that end, neither `pytorch` nor `tensorflow` are pre-installed here, 
so that will need to be done by images built on top of `terra-jupyter-minimal-gpu-base`.

To see the complete contents of this image please see the 
[Dockerfile](../terra-jupyter-minimal-base/Dockerfile) (the same Dockerfile as 
`terra-jupyter-minimal-base`),
which builds `FROM nvcr.io/nvidia/cuda:11.3.1-base-ubuntu20.04`
(the build command is [here](./build_docker.sh)).

## Selecting prior versions of this image

To select an older version this image, you can search the [CHANGELOG.md](./CHANGELOG.md) 
for a specific package version you need.

Once you find an image version that you want, simply copy and paste the image 
url from the changelog into the corresponding custom docker field in the Terra 
notebook runtime widget. 
