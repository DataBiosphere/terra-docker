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
