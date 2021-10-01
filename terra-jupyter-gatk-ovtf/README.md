# terra-jupyter-gatk-ovtf image

This repo contains the `terra-jupyter-gatk-ovtf` image that is compatible with notebook service in [Terra](https://app.terra.bio/) called Leonardo. 

To use this in [Terra](https://app.terra.bio/), use `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-gatk-ovtf:0.1.0` as image identifier.


## Image contents

The `terra-jupyter-gatk-ovtf` docker image extends the [terra-jupyter-python](../terra-jupyter-python/README.md) and [terra-jupyter-r](../terra-jupyter-r/README.md) by including the following:

- Open JDK
- GATK
- Samtools
- [OpenVINO integration with TensorFlow](https://github.com/openvinotoolkit/openvino_tensorflow) (OVTF)

To see the complete contents of this image please see the [Dockerfile](./Dockerfile).

## Sample Notebook

This repo provides a sample notebook [GATK-OVTF-Notebook.ipynb](./GATK-OVTF-Notebook.ipynb) which showcases the performance benefits obtained by using OpenVINO™ integration with TensorFlow.

## Build and Run Instructions - **Locally**

- ### Clone the repository

  ```bash
  git clone https://github.com/DataBiosphere/terra-docker

  ```

- ### Build the docker image

  ```bash
  cd terra-docker/terra-jupyter-gatk-ovtf
  docker build . -t terra-jupyter-gatk-ovtf
  ```

- ### Run the container, Then navigate a browser to http://localhost:8000/notebooks to access the Jupyter UI

  ```bash
  docker run --rm -it -p 8000:8000 terra-jupyter-gatk-ovtf
  ```

- ### You can gain root access and open a bash terminal as follows:

  ```bash
  docker run --rm -it -u root -p 8000:8000 --entrypoint /bin/bash terra-jupyter-gatk-ovtf
  ```

## Selecting prior versions of this image

To select an older version this image, you can search the [CHANGELOG.md](./CHANGELOG.md) for a specific package version you need.

Once you find an image version that you want, simply copy and paste the image url from the changelog into the corresponding custom docker field in the Terra notebook runtime widget.
