# terra-jupyter-gatk-ovtf image

This repo contains the terra-jupyter-gatk-ovtf image that is compatible with notebook service in [Terra]("https://app.terra.bio/") called Leonardo. For example, use `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-gatk-ovtf:{version}` in terra.

## Image contents

The terra-jupyter-gatk extends the [terra-jupyter-python](../terra-jupyter-python/README.md) and [terra-jupyter-r](../terra-jupyter-r/README.md) by including the following:

- Open JDK 
- GATK
- Samtools
- [OpenVINO integration with TensorFlow](https://github.com/openvinotoolkit/openvino_tensorflow) (OVTF)

To see the complete contents of this image please see the [Dockerfile](./Dockerfile).

## Sample Notebook

This repo provides a sample notebook [GATK-OVTF-Notebook.ipynb](./GATK-OVTF-Notebook.ipynb) which showcases the performance benefits obtained by using OpenVINO™ integration with TensorFlow.

## Selecting prior versions of this image

To select an older version this image, you can search the [CHANGELOG.md](./CHANGELOG.md) for a specific package version you need.

Once you find an image version that you want, simply copy and paste the image url from the changelog into the corresponding custom docker field in the Terra notebook runtime widget. 
