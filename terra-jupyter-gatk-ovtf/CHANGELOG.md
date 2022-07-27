## 0.2.6 - 2022-07-27T13:32:20.053219Z

- Update `terra-jupyter-r` to `2.1.6`
  - Installs AnVIL and supporting packages.

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-gatk-ovtf:0.2.6`

## 0.2.5 - 2022-06-23T10:58:12.961300Z

- Update `terra-jupyter-base` to `1.0.10`
  - Fix leo_url variable in workspace_cromwell.py script for AoU projects

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-gatk-ovtf:0.2.4`

## 0.2.4 - 2022-06-23T10:58:12.961300Z

- reverted, do not use

## 0.2.3 - 2022-05-20T18:06:39.600661Z

- Update `terra-jupyter-base` to `1.0.9`
  - Fix adding workspace_cromwell.py script to manage Cromwell App

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-gatk-ovtf:0.2.3`

## 0.2.2 - 2022-05-17T17:14:41.382147Z

- Update `terra-jupyter-base` to `1.0.8`
  - Add script that manages Cromwell app

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-gatk-ovtf:0.2.2`

## 0.2.1 - 2022-05-10T22:08:26.070940Z

- Update `terra-jupyter-base` to `1.0.7`
  - Install Cromshell 2.0 (https://github.com/broadinstitute/cromshell)

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-gatk-ovtf:0.2.1`

## 0.2.0 - 2022-05-02

- Update `terra-jupyter-r` to `2.1.0`
  - Update Bioconductor to 3.15.0 and R to 4.2.0

## 0.1.10 - 2022-05-02T14:33:24.040339Z

- Update `terra-jupyter-base` to `1.0.6`
  - use new nvidia key

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-gatk-ovtf:0.1.10`

## 0.1.9 - 2022-04-17

- Update `terra-jupyter-base` to `1.0.5`
  - Install gcloud alpha storage dependency

## 0.1.8 - 2022-02-02T20:47:42.409160Z

- Update `terra-jupyter-base` to `1.0.4`
  - update notebook_dir to $HOME; install scikit-learn-intelex, xgboost

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-gatk-ovtf:0.1.8`

## 0.1.7 - 2022-01-26T17:05:04.719540Z

- OVTF1.1.0 released, Updated to GATK 4.2.4.1, TF2.7, GPU support enabled

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-gatk-ovtf:0.1.7`

## 0.1.6 - 2022-01-06T18:21:41.248206Z

- Update `terra-jupyter-base` to `1.0.3`
  - Bumping Google Deeplearning image to 2.7, removing gcc-6 and gcc-8 install due to package problems

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
