# terra-jupyter-base image

This repo contains the terra-jupyter-base image that is compatible with notebook service in [Terra]("https://app.terra.bio/") called Leonardo. For example, use `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-base:{version}` in terra.

## Image contents
- Ubuntu 26.04 (`nvidia/cuda:13.4.2-base-ubuntu26.04`)
- OS prerequisites
- google-cloud-cli (gcloud, gsutil, bq)
- Python 3.13 (Miniconda), with three separate environments:
  - `/opt/conda/envs/python3` (`$CONDA_ENV_HOME`): the user's conda env, which the `python3` notebook kernel runs
  - `/etc/jupyter`: an isolated uv venv for the Jupyter server, from [pyproject.toml](./pyproject.toml) / [uv.lock](./uv.lock)
  - `/opt/conda`: conda base
  - Ubuntu's own `/usr/bin/python3` is 3.14; it is not used for notebooks
- pip, in the user's conda env (there is no system `pip3`). `PIP_USER=true`, so `pip install` in a notebook installs to `~/.local`
- conda
- Jupyter Notebook 7, nbclassic & JupyterLab
- Leonardo customizations/extensions
- Terra python client libraries ([FISS](https://github.com/broadinstitute/fiss), [terra-notebook-utils](https://github.com/DataBiosphere/terra-notebook-utils))
- R and the CRAN apt repository (`r-base`, `r-base-dev`); the R kernel is added by [terra-jupyter-r](../terra-jupyter-r)
- OpenJDK 25

## Installing Python packages in images built on this one

Install into the user's conda env, not with a bare `pip`/`pip3` (that resolves to conda base):

```dockerfile
RUN $CONDA_ENV_HOME/bin/python -m pip install <package>
# or, from a pyproject.toml
RUN uv pip install --python $CONDA_ENV_HOME/bin/python -r pyproject.toml
```

The `python3` kernel is registered in `/usr/local/share/jupyter/kernels`.

To see the complete contents of this image please see the [Dockerfile](./Dockerfile).

## Conda environments

`conda install` and `conda create` use the conda-forge, bioconda and defaults channels, in that order, with
strict channel priority.

Conda envs live in `/opt/conda/envs`, which is part of the image, so they are lost when the runtime is
recreated. Only `/home/jupyter` is on the persistent disk. To keep them:

- After every conda command that changes an env, a conda plugin (`conda/plugin`) saves each env you created
  to `/home/jupyter/<env>-environment.yml`. The file lists the packages you asked for and your pip
  packages. Removing the env deletes its file. `base` and `python3` come from the image and are not saved.
- When Jupyter starts, `run-jupyter.sh` recreates any missing env from those files in the background
  (`scripts/restore-conda-envs.sh`, log in `~/.conda-restore.log`). A large env can take several minutes,
  so its kernel may not be usable straight away.
- Delete an `<env>-environment.yml` file to stop that env from being recreated.

## Selecting prior versions of this image

To select an older version this image, you can search the [CHANGELOG.md](./CHANGELOG.md) for a specific package version you need.

Once you find an image version that you want, simply copy and paste the image url from the changelog into the corresponding custom docker field in the Terra notebook runtime widget. 
