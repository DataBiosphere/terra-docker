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
