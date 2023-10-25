# terra-base image

This repo contains the terra-base image that is compatible with the
notebook service in [Terra]("https://app.terra.bio/") called Leonardo.
The goal is to provide a lean, GPU-enabled base image that can be use for both Terra-suported, and custome image builds.
[See design doc]("https://broadworkbench.atlassian.net/wiki/spaces/IA/pages/2842460165/2023-08-28+Terra+Docker+Refactoring+POC#Provide-a-leaner-set-of-terra-docker-images")

## Image contents

`terra-base` extends an cuda 12.2.0 and Ubuntu 22.04 base image with the minimum 
requirements necessary to set up Jupyter and provide compatibility with Leonardo and GPU machines.

- OS prerequisites
- Python 3.10
- R 4.1.2
- Anaconda
- Jupyter
- Leonardo customizations/extensions
- Terra python client library ([FISS](https://github.com/broadinstitute/fiss))
- Terra notebook utils
- Full list of python packages is available [here](pyproject.toml)

To see the complete contents of this image please see the [Dockerfile](./Dockerfile).

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

From inside the `terra-base` directory, run the following command to install
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