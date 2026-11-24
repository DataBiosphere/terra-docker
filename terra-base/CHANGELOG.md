## 2.0.0 - 11/24/2026

Breaking changes for images built `FROM terra-base`:

- Extends `terra-core` (Ubuntu 26.04) with the CUDA 13.5 runtime, in place of `nvidia/cuda:13.0.1-base-ubuntu22.04`
- Python 3.13 (was 3.10, end of life) for Jupyter and the user conda environment; Miniconda `py313_26.9.4-1`
- JupyterLab 4.6, Notebook 7.6 and jupyter-server 2.21 (was JupyterLab 3.4, Notebook 6.5 and jupyter-server 1.24)
- Classic nbextensions are no longer loaded, including `jupyter-contrib-nbextensions`. Edit mode, playground mode and the Terra UI iframe integration are in the new `terra-jupyterlab-extension`, which works in both Notebook 7 and JupyterLab 4
- Node 24 (was 20, end of life), R from CRAN for Ubuntu 26.04, apt keys via `signed-by` keyrings
- Server settings moved to `jupyter_server_config.py`; adds `api/terra/config`
- The `python3` kernel runs the user's conda env Python by absolute path (1.x launched whichever `python3` was first on `PATH`)
- Installs IRkernel, so the registered `r` kernel starts (1.x registered it without IRkernel)

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-base:2.0.0`

## 1.0.0 - 12/16/2025

- Extends GPU-enabled Ubuntu base image
- Uses Python 3.10
- Add UV
- Add conda
- Add Jupyter
- Add Leonardo customizations/extensions

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-base:1.0.0`
