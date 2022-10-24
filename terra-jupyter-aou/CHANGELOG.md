## 2.1.12 - 2022-10-21
- Update `hail` to `0.2.104`
  - See https://hail.is/docs/0.2/change_log.html#version-0-2-104) for details

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-aou:2.1.12`

## 2.1.11 - 2022-10-04
- Update `hail` to `0.2.101`
  - See https://hail.is/docs/0.2/change_log.html#version-0-2-101) for details

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-aou:2.1.11`

## 2.1.10 - 2022-09-23
- Update `hail` to `0.2.100`
  - See https://hail.is/docs/0.2/change_log.html#version-0-2-100) for details

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-aou:2.1.10`

## 2.1.9 - 2022-09-02

 - Add support for QIIME2
 - Update `hail` to `0.2.98`
   - See https://hail.is/docs/0.2/change_log.html#version-0-2-98) for details

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-aou:2.1.9`

## 2.1.8 - 2022-07-12

- Revert attempted Java11 upgrade back to Java8

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-aou:2.1.8`

## 2.1.7 - 2022-06-30
- Update `hail` to `0.2.96`
  - See https://hail.is/docs/0.2/change_log.html#version-0-2-96) for details

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-aou:2.1.7`

## 2.1.6 - 2022-06-23T10:58:12.961300Z

- Update `terra-jupyter-base` to `1.0.10`
  - Fix leo_url variable in workspace_cromwell.py script for AoU projects

## 2.1.5 - 2022-06-09

- Update `terra-jupyter-gatk` base to `2.2.5`
  - Fix Python sites-packages to avoid issues on uninstall
- Bump Hail to 0.2.93

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-aou:2.1.5`

## 2.1.4 - 2022-06-03T18:35:22.582705Z

- reverted, do not use

## 2.1.3 - 2022-05-20T18:06:39.587654Z

- Update `terra-jupyter-base` to `1.0.9`
  - Fix adding workspace_cromwell.py script to manage Cromwell App

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-aou:2.1.3`

## 2.1.2 - 2022-05-17T17:14:41.365718Z

- Update `terra-jupyter-base` to `1.0.8`
  - Add script that manages Cromwell app

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-aou:2.1.2`

## 2.1.1 - 2022-05-10T22:08:26.056998Z

- Update `terra-jupyter-base` to `1.0.7`
  - Install Cromshell 2.0 (https://github.com/broadinstitute/cromshell)

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-aou:2.1.1`

## 2.1.0 - 2022-05-02

- Update `terra-jupyter-r` to `2.1.0`
  - Update Bioconductor to 3.15.0 and R to 4.2.0

## 2.0.15 - 2022-05-02T14:33:24.031254Z

- Update `terra-jupyter-base` to `1.0.6`
  - use new nvidia key
- Update `terra-jupyter-gatk` to `2.1.0`
  - Install Nextflow in GATK image

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-aou:2.0.15`

## 2.0.14 - 2022-04-17

- Update `terra-jupyter-gatk` to `2.0.9`
  - Install gcloud alpha storage dependency
- Install SAIGE
- Add igv-jupyter extension by default

## 2.0.13 - 2022-03-18

- Update `terra-jupyter-gatk` to `2.0.8`
- Update Hail installation to latest

## 2.0.12 - 2022-02-02T20:47:42.403024Z

- Update `terra-jupyter-base` to `1.0.4`
  - update notebook_dir to $HOME; install scikit-learn-intelex, xgboost

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-aou:2.0.12`

## 2.0.11 - 2022-01-25

- Add additional genomics tools: gcta, PRsice, vcftools, plink2

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-aou:2.0.11`

## 2.0.10 - 2022-01-06T18:21:41.240337Z

- Update `terra-jupyter-base` to `1.0.3`
  - Bumping Google Deeplearning image to 2.7, removing gcc-6 and gcc-8 install due to package problems

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-aou:2.0.10`

## 2.0.9 - 2021-12-14T19:48:03.857067Z

- Update `terra-jupyter-r` to `2.0.3`
  - Update Terra Jupyter image to use latest Bioconductor 3.14

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-aou:2.0.9`

## 2.0.8 - 2021-12-16

- Bump Hail version to 0.2.74

## 2.0.7 - 2021-12-15T18:29:12.526374Z
- Update `terra-jupyter-gatk` base image to `2.0.5`
  - Upgrade gatk image to 4.2.4.0

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-aou:2.0.7`

## 2.0.6 - 2021-12-13

- Update `terra-jupyter-gatk` base image to `2.0.4`
  - Update AsyncMappingKernelManager https://github.com/jupyter/notebook/issues/6164

## 2.0.5 - 2021-12-02T21:50:37.297833

- Fix nextflow install path.

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-aou:2.0.5`

## 2.0.4 - 2021-11-24T05:51:34.197137

- Install nextflow
- Update  bolt lmm to 2.3.6
Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-aou:2.0.4`

## 2.0.3 - 2021-10-07T14:47:43.445699Z

- Unpinning cwltool version and updating protobuf version to 3.18

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-aou:2.0.3`

## 2.0.2 - 2021-09-10T15:10:44.156815Z

- Update `terra-jupyter-base` to `1.0.1`
  - Update base image to gcr.io/deeplearning-platform-release/tf2-gpu.2-6 to support TensorFlow 2.6.0
  - Fix multipart Jupyter uploads

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-aou:2.0.2`

## 2.0.1 - 2021-07-20

- Upgrade `terra-jupyter-gatk` to `2.0.1`

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-aou:2.0.1`

## 2.0.0 - 2021-06-28T19:39:56.024375Z

- Update `terra-jupyter-base` to `1.0.0`
  - use `gcr.io/deeplearning-platform-release/base-cu110:latest` as base

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-r:2.0.0`

## 1.1.7 - 2021-06-30

- Add less
- Add papermill
- Install a global gitignore to ensure that by default only code files and documentation are commited to source control.

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-aou:1.1.7`

## 1.1.6 - 2021-06-07T19:39:56.024375Z

- Update `terra-jupyter-r` to `1.0.16`
  - Update R to 4.1.0 and Bioconductor version to 3.13.

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-aou:1.1.6`

## 1.1.5 - 2021-05-24

- Reduce unnecessary package upgrades.

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-aou:1.1.5`

## 1.1.4 - 2021-05-24

- Add bcftools

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-aou:1.1.4`

## 1.1.3 - 2021-05-05T16:19:57.558388Z

- Update `terra-jupyter-base` to `0.0.20`
  - [IA-1644] Install crcmod in base image to support GCS composite objects

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-aou:1.1.3`

## 1.1.2 - 2021-04-21

- Refactor to terra-jupyter-gatk:1.1.1 as the base image
  - GATK now included
  - samtools now included
- Install bolt-lmm
- Install regenie
- Install Nirvana
- Install R packages: SAIGE, GENESIS
- Update Plink version

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-aou:1.1.2`

## 1.1.1 - 2021-04-05T17:29:05.447Z

- Update `terra-jupyter-python` to `0.1.1`
  - fix ggplot import bug

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-aou:1.1.1`

## 1.1.0 - 2021-03-20

- Update `terra-jupyter-python` to `0.1.0`
- Remove more Python package overrides which are no longer needed due to updates in the base Python image.
- Add nbstripout and enable it globally so that its in effect for any git repository cloned to the VM.

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-aou:1.1.0`

## 1.0.23 - 2021-02-22

- Remove varstore scripts / GATK jar
- Upgrade Hail
- Remove some Python package / R lib overrides which are no longer needed

## 1.0.22 - 2021-02-10T00:36:57.205Z

- Update `terra-jupyter-r` to `1.0.13`
  - [IA-2511] Install Seurat R package in terra-jupyter-r image

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-aou:1.0.22`

## 1.0.21 - 2021-01-20T16:00:48.370Z

- Update `terra-jupyter-base` to `0.0.19`
  - [IA-2472] Turn on debug-level logging when JUPYTER_DEBUG_LOGGING env var is true

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-aou:1.0.21`

## 1.0.20 - 2020-12-09T18:50:57.334Z

- Update `terra-jupyter-python` to `0.0.22`
  - [IA-2420] Update to a newer version of pymc3
- Update hail version to `0.2.61`

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-aou:1.0.20`

## 1.0.19 - 2020-12-02T17:59:36.458Z

- Update `terra-jupyter-base` to `0.0.18`
  - bump terra-notebook-utils version to 0.7.0 and move it to base image

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-aou:1.0.19`

## 1.0.18 - 2020-11-16T18:11:40.848741Z

- Remove dependency on miniconda
- Update `terra-jupyter-base` to `0.0.17`
  - remove miniconda

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-aou:1.0.18`

## 1.0.17 - 2020-11-10T13:26:19.148Z

- Update `terra-jupyter-python` to `0.0.19`
  - Remove Python package enum34. Fixes https://github.com/DataBiosphere/terra-docker/issues/175

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-aou:1.0.17`

## 1.0.16 - 2020-11-04T21:43:54.919Z

- Update `terra-jupyter-r` to `1.0.9`
  - Version upgrades: Bioconductor version 3.12 and R version 4.0.3

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-aou:1.0.16`

## 1.0.15 - 2020-10-26T20:13:57.770Z

- Update `terra-jupyter-base` to `0.0.16`
  - add keychain to base image

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-aou:1.0.15`

## 1.0.14 - 2020-10-22

- Don't use gsutil, it creates local credentials files which break downstream CLI usage

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-aou:1.0.14`

## 1.0.13 - 2020-10-21

- Add [variantstore](https://github.com/broadinstitute/variantstore) extraction tool
- Update gatk custom jar build to latest

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-aou:1.0.13`

## 1.0.12 - 2020-10-08T18:42:19.744Z

- Update `terra-jupyter-base` to `0.0.15`
  - include pip binary installation location in PATH

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-aou:1.0.12`

## 1.0.11 - 09/29/2020

 - Just download the custom GATK jar instead of building it.

## 1.0.10 - 09/18/2020

 - Add Hail / Spark libs.
 - Bump GATK jar to latest commit ah_var_store branch:
   https://github.com/broadinstitute/gatk/tree/ah_var_store

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-aou:1.0.10`

## 1.0.9 - 09/17/2020

 - Install plink binary
 - Build/install ah_var_store branch of GATK jar:
   https://github.com/broadinstitute/gatk/tree/ah_var_store

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-aou:1.0.9`

## 1.0.8 - 2020-09-02T15:12:19.917Z

- Update `terra-jupyter-base` to `0.0.14`
  - Terminal now opens to /notebooks directory where PD is mounted

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-aou:1.0.8`

## 1.0.7 - 2020-08-18T13:43:26.277Z

- Update `terra-jupyter-base` to `0.0.13`
  - update notebook to 6.1.1, tornado to 5.1.1

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-aou:1.0.7`

## 1.0.6 - 8/18/2020

- Update to newer TensorFlow python package.
- Update numpy to match documented version.
- Reinstall AoU fork of bigrquery (new patch taken from ahead of the main package)

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-aou:1.0.6`

## 1.0.5 - 07/27/2020

- Update `terra-jupyter-python` to `0.0.14`
- Update `terra-jupyter-r` to `1.0.4`

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-aou:1.0.5`

## 1.0.4 - 07/28/2020

- Drop fork install of bigrquery (patches have now been merged and released in the main bigrquery package)
- Install new AoU Python library
- Avoid installing pandas 1.0 for now; pin other packages

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-aou:1.0.4`

## 1.0.3 - 06/29/2020

- Only user package installations will persist (installed to `/home/jupyter-user/notebooks/packages`) not image installed packages
- Update `terra-jupyter-r` base image to `1.0.3`
- Update `terra-jupyter-aou` to version `1.0.3`

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-aou:1.0.3`

## 1.0.2 - 06/26/2020

- Update `terra-jupyter-r` base image to `1.0.2`
- Update `terra-jupyter-aou` to version `1.0.2`

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-aou:1.0.2`

## 1.0.1 - 06/15/2020

- Update `terra-jupyter-r` base image to `1.0.1` and `terra-jupyter-python` base image to `0.0.13`
- Update `terra-jupyter-aou` to version `1.0.1`

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-aou:1.0.1`

## 1.0.0 - 05/21/2020

- Update `terra-jupyter-aou` to version `1.0.0`
- Update `terra-jupyter-r` base image to `1.0.0`

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-aou:1.0.0`

## 0.0.4 - 05/18/2020

- Update `terra-jupyter-python` base image to `0.0.12` and `terra-jupyter-r` base image to `0.0.14`
   - Adds jupyter notebook extension collapsible headers and code-folding

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-aou:0.0.4`

## 0.0.3 - 04/28/2020

- Update `terra-jupyter-python` base image to `0.0.11`
  - Add Google Cloud support to pysam

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-aou:0.0.3`

## 0.0.2 - 04/24/2020

- Update to `terra-jupyter-r:0.0.13`.
- Update `terra-jupyter-aou` image version to `0.0.2`.

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-aou:0.0.2`

## 0.0.1 - 02/28/2020

- Iniitalized image; based on terra-jupyter-gatk, combined with the original
  [All of Us initialization script](https://github.com/all-of-us/workbench/blob/5ee08d7cd8f069963e5d35877b711c0643e1c8b5/api/cluster-resources/initialize_notebook_cluster.sh)

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-aou:0.0.1`
