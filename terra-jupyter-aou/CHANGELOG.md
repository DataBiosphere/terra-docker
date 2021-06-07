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
