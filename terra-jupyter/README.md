# terra-jupyter image

The base image for custom Jupyter images in [Terra](https://app.terra.bio/), run by Leonardo as a cloud environment. It replaces [`terra-base`](../terra-base), which stays at 1.x for existing images. Use `us.gcr.io/broad-dsp-gcr-public/terra-jupyter:{version}`.

## Context
This image is different from the legacy base image that is currently use to build the docker images cached in Terra (terra-jupyter-base).
The current purpose of this new base image is to to unblock users from creating custom images in Terra.

## Image contents

`terra-jupyter` extends [`terra-core`](../terra-core) (Ubuntu 26.04) with:

- the CUDA 13.5 runtime (as in `nvidia/cuda:13.5.0-base-ubuntu26.04`)
- Python 3.13, with Conda for the user's environment
- Jupyter Server 2, Notebook 7 and JupyterLab 4
- R, Node 24 and `uv`
- Leonardo customizations: the Welder contents manager and server extension in [`custom`](./custom),
  and [`terra-jupyterlab-extension`](./jupyterlab-extension) for edit mode, playground mode and the
  Terra UI iframe integration

To see the complete contents of this image please see the [Dockerfile](./Dockerfile).

## Testing

```bash
./build_smoke_test_image.sh terra-jupyter
./terra-jupyter/tests/contract_test.sh terra-jupyter:smoke-test
```

The contract test checks what Leonardo and Terra UI expect from the image and runs the Python tests
in [`tests`](./tests) inside it.

## Selecting prior versions of this image

To select an older version this image, you can search the [CHANGELOG.md](./CHANGELOG.md) for a specific package version you need.

Once you find an image version that you want, simply copy and paste the image url from the changelog into the corresponding custom docker field in the Terra notebook runtime widget. 

## Updating the UV packages
 To update UV packages, first cd into the `terra-jupyter` directory, then either:
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
 docker build terra-jupyter -t us.gcr.io/broad-dsp-gcr-public/terra-jupyter:{version}
 docker push us.gcr.io/broad-dsp-gcr-public/terra-jupyter:{version}
```

## NOTE:  Changing paths
If you change the following paths:
- `JUPYTER_HOME`
- `JUPYTER_USER`
- `CONDA_HOME` 

You may need to update the following files appropriately here and in Leonardo:
- terra-docker
  - `run_jupyter.sh`
  - the notebook extension scripts
- leonardo
  - `gce-init.sh`
  - `init-action.sh`
  - the `jupyterUserhome` in RuntimeTemplateValues 