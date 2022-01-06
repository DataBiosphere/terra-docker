## 0.1.6 - 2022-01-06T18:21:41.248206Z

- Update `terra-jupyter-base` to `1.0.3`
  - Bumping Google Deeplearning image to 2.7, removing gcc-6 install due to package problems

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-gatk-ovtf:0.1.6`

## 0.1.5 - 2021-12-14T19:48:03.867076Z

- Update `terra-jupyter-r` to `2.0.3`
  - Update Terra Jupyter image to use latest Bioconductor 3.14

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-gatk-ovtf:0.1.5`

## 0.1.4 - 2021-12-15T18:30:57.568303Z

- Upgrade gatk image to 4.2.4.0

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-gatk-ovtf:0.1.4`

## 0.1.3 - 2021-10-07T14:47:43.454585Z

- Update `terra-jupyter-base` to `1.0.2`
  - Update AsyncMappingKernelManager https://github.com/jupyter/notebook/issues/6164
- Unpinning cwltool version and updating protobuf version to 3.18

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-gatk-ovtf:0.1.3`

## 0.1.2 - 2021-09-22T15:25:34.080267Z

- Intel OVTF patch for updating to TF2.6.0/2.5.0

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-gatk-ovtf:0.1.2`

## 0.1.1 - 2021-09-10T15:10:44.164165Z

- Update `terra-jupyter-base` to `1.0.1`
  - Update base image to gcr.io/deeplearning-platform-release/tf2-gpu.2-6 to support TensorFlow 2.6.0
  - Fix multipart Jupyter uploads

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-gatk-ovtf:0.1.1`

## 0.1.0 - 08/25/2021

- Added OpenVINO integration with TensorFlow (OVTF)