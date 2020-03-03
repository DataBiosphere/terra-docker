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
