# terra-jupyter-base image

This repo contains the terra-jupyter-base image that is compatible with notebook service in [Terra]("https://app.terra.bio/") called Leonardo. For example, use `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-base:{version}` in terra.

## Image contents

The terra-jupyter-base extends the [Ubuntu base image]() TODO by including the following:

- OS prerequisites
- google-cloud-sdk
- Python 3.10
- conda
- Jupyter & JupyterLab
- Leonardo customizations/extensions
- Terra notebook utils

To see the complete contents of this image please see the [Dockerfile](./Dockerfile).

## Selecting prior versions of this image

To select an older version this image, you can search the [CHANGELOG.md](./CHANGELOG.md) for a specific package version you need.

Once you find an image version that you want, simply copy and paste the image url from the changelog into the corresponding custom docker field in the Terra notebook runtime widget. 

## Updating the UV packages
 To update UV packages, first cd into the`terra-base` directory, then either:
  - run `uv add <package_name>`  or remove to add or remove a specific package in the project
 - modify the pyproject.toml file, then run `uv lock`

To activate a virtual environment for local testing:
```bash
source .venv/bin/activate
uv sync
```
(.venv is created when you run `uv install`)

## Building the image
To build the image locally, run the following command in the root of the repo:

```bash
 docker build terra-base -t us.gcr.io/broad-dsp-gcr-public/terra-base:{version}
 docker push us.gcr.io/broad-dsp-gcr-public/terra-base:{version}
```

## NOTE:  Changing paths
If you change the following paths for the:
- `JUPYTER_HOME`
- `JUPYTER_USER`
- `CONDA_HOME` 

You may need to update the following files appropriately:
- terra-docker
  - `conda_init.txt`
  - `run_jupyter.sh`
  - the notebook extension scripts
- leonardo
  - `gce-init.sh`
  - the `jupyterUserhome` in RuntimeTemplateValues 