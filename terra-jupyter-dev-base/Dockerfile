FROM ubuntu:20.04

USER root

# The welder uid is consistent with the Welder docker definition here:
# https://github.com/DataBiosphere/welder/blob/master/project/Settings.scala
# Adding welder-user to the Jupyter container isn't strictly required, but it makes welder-added
# files display nicer when viewed in a terminal.
ENV DEBIAN_FRONTEND=noninteractive \
    LC_ALL=en_US.UTF-8 \
    USER=jupyter \
    WELDER_USER=welder-user \
    WELDER_UID=1001 \
    # ensure this matches c.NotebookApp.port in jupyter_notebook_config.py
    JUPYTER_PORT=8000 \
    JUPYTER_HOME=/etc/jupyter \
    CONDA_AUTO_UPDATE_CONDA=false \
    CONDA_DIR=/opt/conda
ENV HOME=/home/$USER
    # When using PIP_USER=true packages are installed into Python site.USER_BASE, which is '/home/jupyter' for this system.
    # Append '/home/jupyter/.local/bin' to PATH
    # pip docs: https://pip.pypa.io/en/stable/reference/pip_install/#cmdoption-user
ENV PATH="${PATH}:${CONDA_DIR}/bin:${HOME}/.local/bin:${HOME}/packages/bin"

# Users
RUN useradd -m -s /bin/bash $USER \
 && usermod -g users $USER \
 && useradd -m -s /bin/bash -N -u $WELDER_UID $WELDER_USER \
# Prerequisites
 && apt-get update && apt-get install -yq --no-install-recommends \
    sudo \
 && sudo -i \
    echo "deb http://security.ubuntu.com/ubuntu/ bionic main" >> /etc/apt/sources.list \
    sudo apt update libexempi3 \
 && sudo -i \
    echo "deb http://us.archive.ubuntu.com/ubuntu/ bionic universe" >> /etc/apt/sources.list \
    sudo apt update libv8-3.14-dev \
 && apt-get update && apt-get install -yq --no-install-recommends \
    # gnupg requirement
    dirmngr \
    gnupg \
    # curl requirement
    curl \
    ca-certificates \
    # useful utilities for debugging within the docker
    nano \
    procps \
    # extras \
    wget \
    bzip2 \
    # install script requirements
    locales \
    # for ssh-agent and ssh-add
    keychain \
    # git
    git \
 # Uncomment en_US.UTF-8 for inclusion in generation
 && sed -i 's/^# *\(en_US.UTF-8\)/\1/' /etc/locale.gen \
 # Generate locale
 && locale-gen \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
# install miniconda to $CONDA_DIR
 && curl -so $HOME/miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-py37_4.12.0-Linux-x86_64.sh \
 && chmod +x $HOME/miniconda.sh \
 && $HOME/miniconda.sh -b -p $CONDA_DIR \
 && rm $HOME/miniconda.sh \
# slim install of python packages that have a gcc dependency (cleanup included)
 && apt-get update && apt-get install -y --no-install-recommends \
    checkinstall \
    build-essential \
    zlib1g-dev \
    # pip requirements
    libssl-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    llvm \
    libncurses5-dev \
    libncursesw5-dev \
    tk-dev \
    libffi-dev \
    liblzma-dev \
    python-openssl \
    libexempi3 \
    libv8-3.14-dev \
 && rm -rf /var/lib/apt/lists/* \
 && pip3 install firecloud  \
 && pip3 install terra-notebook-utils \
 && apt-get purge -y --auto-remove \
    checkinstall \
    build-essential \
    zlib1g-dev \
    # pip requirements
    libssl-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    llvm \
    libncurses5-dev \
    libncursesw5-dev \
    tk-dev \
    libffi-dev \
    liblzma-dev \
    python-openssl \
    libexempi3 \
    libv8-3.14-dev \
# Install jupyter and some necessary python packages
 && pip3 -V \
 # For gcloud alpha storage support.
 && pip3 install google-crc32c --target /usr/lib/google-cloud-sdk/lib/third_party \
 && git clone --branch cromshell_2.0 --single-branch \
    https://github.com/broadinstitute/cromshell.git $HOME/cromshell \
 # tmp hack min-5
 # I'm not installing jupyterlab and I can't update init-actions.sh to not access it
 && mkdir -p /usr/local/share/jupyter/lab \
 # When we upgraded from jupyter 5.7.8 to 6.1.1, we broke terminal button on terra-ui.
 # Hence, make sure to manually test out "launch terminal" button (the button in the green bar next to start and stop buttons)
 # to make sure we don't accidentally break it every time we upgrade notebook version until we figure out an automation test for this
 && pip3 install notebook \
 && pip3 install jupyter \
# && pip3 install jupyterlab \
 && pip3 install cookiecutter \
 && pip3 install tornado \
 && pip3 install python-datauri \
 && pip3 install jupyter_contrib_nbextensions \
 && pip3 install jupyter_nbextensions_configurator \
 && pip3 install markupsafe==2.0.1 \
 # Avoid broken lower versions: https://github.com/jupyter/nbconvert/pull/1624
 && pip3 install "nbconvert>=6.4.5" \
 # for jupyter_delocalize.py and jupyter_notebook_config.py
 && pip3 install requests \
 && pip3 install crcmod \
 # install Cromshell 2.0, using repo cloned above
 && pip install $HOME/cromshell \
# copy workspace_cromwell.py script and make it runnable by all users
 && curl -o /usr/local/bin/workspace_cromwell.py https://raw.githubusercontent.com/broadinstitute/cromwhelm/1ceedf89587cffd355f37401b179001f029f77ed/scripts/workspace_cromwell.py \
 && chmod +x /usr/local/bin/workspace_cromwell.py

# Utilities
COPY scripts $JUPYTER_HOME/scripts
COPY custom $JUPYTER_HOME/custom
COPY jupyter_notebook_config.py $JUPYTER_HOME

RUN chown -R $USER:users $JUPYTER_HOME \
 # Disable nb_conda for now. Consider re-enable in the future
# && jupyter nbextension disable nb_conda --py --sys-prefix \
 && find $JUPYTER_HOME/scripts -name '*.sh' -type f | xargs chmod +x \
 # You can get kernel directory by running `jupyter kernelspec list`
 && $JUPYTER_HOME/scripts/kernel/kernelspec.sh $JUPYTER_HOME/scripts/kernel $CONDA_DIR/share/jupyter/kernels

# make pip install to a user directory, instead of a system directory which requires root.
# this is useful so `pip install` commands can be run in the context of a notebook.
ENV PIP_USER=true
USER $USER
EXPOSE $JUPYTER_PORT
WORKDIR $HOME

# Note: this entrypoint is provided for running Jupyter independently of Leonardo.
# When Leonardo deploys this image onto a cluster, the entrypoint is overwritten to enable
# additional setup inside the container before execution.  Jupyter execution occurs when the
# init-actions.sh script uses 'docker exec' to call run-jupyter.sh.
ENTRYPOINT ["jupyter", "notebook"]
