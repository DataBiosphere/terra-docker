## 1.0.15 - 2021-06-07T19:39:55.978624Z

- Update `terra-jupyter-r` to `1.0.16`
  - Update R to 4.1.0 and Bioconductor version to 3.13.

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-bioconductor:1.0.15`

## 1.0.14 - 2021-05-05T16:19:57.470153Z

- Update `terra-jupyter-base` to `0.0.20`
  - [IA-1644] Install crcmod in base image to support GCS composite objects

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-bioconductor:1.0.14`

## 1.0.13 - 2021-02-10T00:36:57.149Z

- Update `terra-jupyter-r` to `1.0.13`
  - [IA-2511] Install Seurat R package in terra-jupyter-r image

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-bioconductor:1.0.13`

## 1.0.12 - 2021-01-20T16:00:48.285Z

- Update `terra-jupyter-base` to `0.0.19`
  - [IA-2472] Turn on debug-level logging when JUPYTER_DEBUG_LOGGING env var is true

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-bioconductor:1.0.12`

## 1.0.11 - 2020-12-02T17:59:36.375Z

- Update `terra-jupyter-base` to `0.0.18`
  - bump terra-notebook-utils version to 0.7.0 and move it to base image

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-bioconductor:1.0.11`

## 1.0.10 - 2020-11-16T18:11:40.741594Z

- Update `terra-jupyter-base` to `0.0.17`
  - remove miniconda

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-bioconductor:1.0.10`

## 1.0.9 - 2020-11-04T21:43:54.879Z

- Update `terra-jupyter-r` to `1.0.9`
  - Version upgrades: Bioconductor version 3.12 and R version 4.0.3

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-bioconductor:1.0.9`

## 1.0.8 - 2020-10-26T20:13:57.651Z

- Update `terra-jupyter-base` to `0.0.16`
  - add keychain to base image

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-bioconductor:1.0.8`

## 1.0.7 - 2020-10-08T18:42:19.678Z

- Update `terra-jupyter-base` to `0.0.15`
  - include pip binary installation location in PATH

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-bioconductor:1.0.7`

## 1.0.6 - 2020-09-02T15:12:19.845Z

- Update `terra-jupyter-base` to `0.0.14`
  - Terminal now opens to /notebooks directory where PD is mounted

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-bioconductor:1.0.6`

## 1.0.5 - 2020-08-18T13:43:26.184Z

- Update `terra-jupyter-base` to `0.0.13`
  - update notebook to 6.1.1, tornado to 5.1.1

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-bioconductor:1.0.5`

## 1.0.4 - 07/27/2020

- Update `terra-jupyter-r` version to `1.0.4`

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-bioconductor:1.0.4`

## 1.0.3 - 06/29/2020

- Only user package installations (not image package installations) will persist
- Update `terra-jupyter-r` version to `1.0.3`

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-bioconductor:1.0.3`

## 1.0.2 - 06/26/2020

- Update `terra-jupyter-r` version to `1.0.2`

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-bioconductor:1.0.2`

## 1.0.1 - 06/15/2020

- Update `terra-jupyter-r` version to `1.0.1`

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-bioconductor:1.0.1`

## 1.0.0 - 05/21/2020

- Inherit from terra-jupyter-r:1.0.0.
- This version updates to R-4.0.0 and Bioconductor RELEASE_3_11.
- Update `terra-jupyter-bioconductor` version to `1.0.0`

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-bioconductor:1.0.0`

# 0.0.15 - 05/18/2020

- Update `terra-jupyter-r` base image to `0.0.14`
   - Adds jupyter notebook extension collapsible headers and code-folding

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-bioconductor:0.0.15`

## 0.0.14 - 04/28/2020

- Fix bug in version `0.0.13`: switch back to `jupyter-user` at the end

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-bioconductor:0.0.14`

## 0.0.13 - 04/24/2020

- Inherit from terra-jupyter-r:0.0.13
- Remove redundant system libraries.
- Update `terra-jupyter-bioconductor` version to `0.0.13`.

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-bioconductor:0.0.13`

## 0.0.12 - 02/25/2020

- Update `terra-jupyter-r` version to `0.0.11`
    - Fixes https://broadworkbench.atlassian.net/browse/IA-1676

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-bioconductor:0.0.12`

## 0.0.11 - 02/05/2020
- Update `terra-jupyter-r` base image to `0.0.10`
   - Fixes https://broadworkbench.atlassian.net/browse/IA-1653

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-bioconductor:0.0.11`

## 0.0.10 - 01/17/2020
- Update `terra-jupyter-r` version to `0.0.9`
- Make docker image locally runnable with:
   - `docker run --rm -it -p 8000:8000 <image>`
- Add FISS library
- Add OpenJDK 11

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-bioconductor:0.0.10`

## 0.0.9 - 12/17/2019
- Upgrade pandas from 0.25.1 to 0.25.3

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-bioconductor:0.0.9`

## 0.0.8 - 12/11/2019
- Standardize both Jupyter and RStudio Bioconductor package installation.
- Update `terra-jupyter-bioconductor` version to `0.0.8`

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-bioconductor:0.0.8`

## 0.0.7 - 11/27/2019
- Use new Bioconductor version 3.10
- Update `terra-jupyter-bioconductor` version to `0.0.7`

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-bioconductor:0.0.7`

## 0.0.6 - 11/26/2019

- Fix `WORKSPACE_BUCKET` environment variable

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-bioconductor:0.0.6`

## 0.0.5 - 11/22/2019
- Install AnnotationHub, ExperimentHub, ensembldb, Rtse, scRNAseq, scran.
- Update `terra-jupyter-bioconductor` version to `0.0.5`

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-bioconductor:0.0.5`

## 0.0.4 - 11/16/2019
- Update `terra-jupyter-r` version to `0.0.5`
- Remove apt-get upgrade for security purposes

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-bioconductor:0.0.4`

## 0.0.3 - 10/18/2019
- Update `terra-jupyter-r` version to `0.0.3`

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-bioconductor:0.0.3`

## 0.0.2 - 09/04/2019
- Install python packages needed for BiocSklearn, Rcwl.
- Install python3.7-dev for headers required to compile python modules.

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-bioconductor:0.0.2`

## 0.0.1 - 09/03/2019
- Add system-dependencies needed for terra-jupyter-r image to install
  Bioconductor packages.
- Install core bioconductor packages to use out of the box.

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-bioconductor:0.0.1`
