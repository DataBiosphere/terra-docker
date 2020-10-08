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
