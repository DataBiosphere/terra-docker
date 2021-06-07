## 1.0.15 - 2021-06-07

- Update R to 4.1.0 and Bioconductor version to 3.13.
- Update terra-jupyter-r image to `1.0.15`

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-r:1.0.15`

## 1.0.14 - 2021-05-05T16:19:57.531117Z

- Update `terra-jupyter-base` to `0.0.20`
  - [IA-1644] Install crcmod in base image to support GCS composite objects
- Fix `libsbml5` installation

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-r:1.0.14`

## 1.0.13 - 2021-02-10T00:36:57.099Z

- [IA-2511] Install Seurat R package in terra-jupyter-r image

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-r:1.0.13`

## 1.0.12 - 2021-01-20T16:00:48.341Z

- Update `terra-jupyter-base` to `0.0.19`
  - [IA-2472] Turn on debug-level logging when JUPYTER_DEBUG_LOGGING env var is true

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-r:1.0.12`

## 1.0.11 - 2020-12-02T17:59:36.434Z

- Update `terra-jupyter-base` to `0.0.18`
  - bump terra-notebook-utils version to 0.7.0 and move it to base image

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-r:1.0.11`

## 1.0.10 - 2020-11-16T18:11:40.819538Z

- Update `terra-jupyter-base` to `0.0.17`
  - remove miniconda

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-r:1.0.10`

## 1.0.9 - 2020-11-04T21:43:54.848Z

- Version upgrades: Bioconductor version 3.12 and R version 4.0.3

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-r:1.0.9`

## 1.0.8 - 2020-10-26T20:13:57.736Z

- Update `terra-jupyter-base` to `0.0.16`
  - add keychain to base image

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-r:1.0.8`

## 1.0.7 - 2020-10-08T18:42:19.728Z

- Update `terra-jupyter-base` to `0.0.15`
  - include pip binary installation location in PATH

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-r:1.0.7`

## 1.0.6 - 2020-09-02T15:12:19.899Z

- Update `terra-jupyter-base` to `0.0.14`
  - Terminal now opens to /notebooks directory where PD is mounted

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-r:1.0.6`

## 1.0.5 - 2020-08-18T13:43:26.250Z

- Update `terra-jupyter-base` to `0.0.13`
  - update notebook to 6.1.1, tornado to 5.1.1

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-r:1.0.5`

## 1.0.4 - 07/27/2020

- Update `terra-jupyter-base` image version to `0.0.12`

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-r:1.0.4`

## 1.0.3 - 06/29/2020
- Remove `/home/jupyter-user/notebooks/packages` from .Renviron file because derived images installed packages should not persist
- Only user package installations (not image package installations) will persist

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-r:1.0.3`

## 1.0.2 - 06/26/2020
- Install all image packages as root user
- remove /home/jupyter-user/.rpackages
- Add /home/jupyter-user/notebooks/packages so user installed packages persist

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-r:1.0.2`

## 1.0.1 - 06/15/2020
- Update `terra-jupyter-base` image version to `0.0.11`
- Add terra-notebook-utils package

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-r:1.0.1`

## 1.0.0 - 05/21/2020
- Update `terra-jupyter-r` version to `1.0.0`
- Update R_VERSION to 4.0 and Bioconductor version to release 3.11.
Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-r:1.0.0`

## 0.0.14 - 05/18/2020
- Update `terra-jupyter-base` image version to `0.0.10`
   - Adds jupyter notebook extension collapsible headers and code-folding
Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-r:0.0.14`

## 0.0.13 - 04/23/2020
- Update `terra-jupyter-r` version to `0.0.13`
- Change env var names to avoid conflict.
Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-r:0.0.13`

## 0.0.12 - 04/15/2020
- Update `terra-jupyter-r` version to `0.0.12`
- Install most system dependencies needed for CRAN and Bioconductor packages.
Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-r:0.0.12`

## 0.0.11 - 02/25/2020
- Update `terra-jupyter-base` version to `0.0.9`
   - Fixes https://broadworkbench.atlassian.net/browse/IA-1676
Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-r:0.0.11`

## 0.0.10 - 02/05/2020
- Update `terra-jupyter-base` version to `0.0.8`
   - Fixes https://broadworkbench.atlassian.net/browse/IA-1653
Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-r:0.0.10`

## 0.0.9 - 01/17/2020
- Update `terra-jupyter-base` version to `0.0.7`
- Make docker image locally runnable with:
   - `docker run --rm -it -p 8000:8000 <image>`
- Add FISS library
- Add OpenJDK 11
Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-r:0.0.9`

## 0.0.8 - 01/15/2020
- Install reticulate.
- Update `terra-jupyter-r` version to `0.0.8`
Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-r:0.0.8`

## 0.0.7 - 11/26/2019
- Update Bioconductor version to 3.10.
- Fix `WORKSPACE_BUCKET` environment variable
- Update `terra-jupyter-r` version to `0.0.7`
Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-r:0.0.7`

## 0.0.6 - 11/22/2019
- Update make recommended packages updatable.
- Update `terra-jupyter-r` version to `0.0.6`
Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-r:0.0.6`

## 0.0.5 - 11/16/2019
- Update `terra-jupyter-base` version to `0.0.5`
- Remove apt-get upgrade for security purposes
Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-r:0.0.5`

## 0.0.4 - 10/18/2019
- Update `terra-jupyter-base` version to `0.0.4`
Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-r:0.0.4`

## 0.0.3 - 09/03/2019
- Install all R packages in same location.
- Make packges updatable with `BiocManager::valid()`
Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-r:0.0.3`

## 0.0.2 - 08/28/2019
- Add devtools R package
- Remove spark
Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-r:0.0.2`

## 0.0.1 - 08/21/2019
- Add R 3.6
Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-r:0.0.1`
