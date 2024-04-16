# terra-base-jupyter image

This repo contains the terra-base-jupyter image that is compatible with the
jupyter notebook service in [Terra]("https://app.terra.bio/") called Leonardo.
The goal is to provide a lean, GPU-enabled base image that can be use for both Terra-suported, and custom image builds.

The goal is to provide the user with a base conda environment where they can install any
package they need, while keeping the jupyter server itself in an isolated virtual environment
that DSP devs control using poetry as the dependency manager

## Image contents

`terra-base-jupyter` extends an cuda 12.2.0 and Ubuntu 22.04 base image with the minimum 
requirements necessary to set up Jupyter and provide compatibility with Leonardo and GPU machines.

- OS prerequisites
- Miniconda with python 3.10
- Two python virtual environments based on miniconda python
-- The user base Conda environment, full list of python packages is available [here](conda-environment.yml)
-- The jupyter virtual environment managed separately by poetry, full list of python packages is available [here](pyproject.toml) that contains the terra-specific configurations (e.g. WelderContentManager)

To see the complete contents of this image please see the [Dockerfile](./Dockerfile).

Note that you can build the image locally and run it by using the following commands from within this directory:

```bash
$> docker build . -t test-base-jupyter
$> docker run --rm -it -p 8888:8888 test-base-jupyter /home/jupyter/ /usr/jupytervenv/bin/jupyter lab --ip 0.0.0.0 --no-browser --allow-root
```

## Contributing

### Installing python 3.10

All terra-docker images are on Python 3.10, so make sure to have it installed on your
local machine, for mac users doing this via `pyenv` is the recommended way of doing it:

```bash
$> brew install pyenv
$> pyenv install 3.10.0
```

### Installing poetry

All python package dependencies are managed by [poetry]("https://python-poetry.org/docs/"),
which allows for cross-platforms, deterministic python environments builds.

You can install poetry via brew or curl commands (NEVER USE PIP!):

```bash
# Via brew
$> brew install poetry
# Via curl
$> curl -sSL https://install.python-poetry.org | python3 -
```

### Managing python packages

**Attention mac m1 users!**

Make sure to do the following before installing any python packages:

```bash
$> brew install libomp
$> brew install llvm
```

For compilers to find libomp and llvm you may need to set either in the terminal directly
or in your bash/zsh profile file:

```bash
$> export LDFLAGS="-L/opt/homebrew/opt/libomp/lib -L/opt/homebrew/opt/llvm/lib"
$> export CPPFLAGS="-I/opt/homebrew/opt/libomp/include -I/opt/homebrew/opt/llvmp/include"
```

From inside the `terra-base-jupyter` directory, run the following command to install
the python 3.10 environment with the relevant packages:

```bash
$> poetry install
```

If you need to update an existing python dependencies, then modify the `pyproject.toml`
file (**it is strongly recommended to never pin an exact version, but floor/ceiling it instead**)
and then update the environment by running the following:

```bash
$> poetry update
```

If you need to add a new dependency, **do not modify the pyproject.toml directly** and do this instead:

```bash
$> poetry add <INSERT_PACKEGE_NAME>
$> poetry update
```

The `poetry update` step will generate a new `poetry.lock` file that will be use in the docker image build.