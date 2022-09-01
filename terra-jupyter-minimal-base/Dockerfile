ARG BASE_IMAGE="ubuntu:20.04"

FROM ${BASE_IMAGE}

USER root

# The welder uid is consistent with the Welder docker definition here:
# https://github.com/DataBiosphere/welder/blob/master/project/Settings.scala
# Adding welder-user to the Jupyter container isn't strictly required, but it makes welder-added
# files display nicer when viewed in a terminal.
ENV DEBIAN_FRONTEND=noninteractive \
    LC_ALL=en_US.UTF-8 \
    GOOGLE_CLOUD_CLI_VERSION="397.0.0" \
    USER=jupyter \
    WELDER_USER=welder-user \
    WELDER_UID=1001 \
    # ensure this matches c.NotebookApp.port in jupyter_notebook_config.py
    JUPYTER_PORT=8000 \
    JUPYTER_HOME=/etc/jupyter \
    CONDA_AUTO_UPDATE_CONDA=false \
    CONDA_DIR=/opt/conda \
    GCLOUD_DIR=/opt/gcloud
ENV HOME=/home/$USER
    # When using PIP_USER=true packages are installed into Python site.USER_BASE, which is '/home/jupyter' for this system.
    # Append '/home/jupyter/.local/bin' to PATH
    # pip docs: https://pip.pypa.io/en/stable/reference/pip_install/#cmdoption-user
ENV PATH="${GCLOUD_DIR}/google-cloud-sdk/bin:${CONDA_DIR}/bin:${HOME}/.local/bin:${HOME}/packages/bin:${PATH}"

COPY requirements.txt /opt/
COPY requirements_gcc.txt /opt/
COPY gcc_pkgs.txt /opt/

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
 && sudo locale-gen \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Install miniconda to $CONDA_DIR
RUN curl -so $HOME/miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-py37_4.12.0-Linux-x86_64.sh \
 && chmod +x $HOME/miniconda.sh \
 && $HOME/miniconda.sh -b -p $CONDA_DIR \
 && rm $HOME/miniconda.sh

# Install gsutil with compiled crcmod
RUN mkdir -p $GCLOUD_DIR \
 && curl -so $GCLOUD_DIR/google-cloud-cli.tar.gz \
    https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-${GOOGLE_CLOUD_CLI_VERSION}-linux-x86_64.tar.gz \
 && tar -xzf $GCLOUD_DIR/google-cloud-cli.tar.gz -C $GCLOUD_DIR \
 && .$GCLOUD_DIR/google-cloud-sdk/install.sh --usage-reporting false --rc-path $HOME/.bashrc \
 # manual symlinks since .bashrc is not getting sourced and PATH is getting overwritten in Terra Cloud Environment
 && ln -s $GCLOUD_DIR/google-cloud-sdk/bin/gsutil /usr/bin/gsutil \
 && ln -s $GCLOUD_DIR/google-cloud-sdk/bin/anthoscli /usr/bin/anthoscli \
 && ln -s $GCLOUD_DIR/google-cloud-sdk/bin/bq /usr/bin/bq \
 && ln -s $GCLOUD_DIR/google-cloud-sdk/bin/docker-credential-gcloud /usr/bin/docker-credential-gcloud \
 && ln -s $GCLOUD_DIR/google-cloud-sdk/bin/gcloud /usr/bin/gcloud \
 # creates the directory $HOME/.config/gcloud/configurations
 && gsutil version -l

# Slim install of python packages that have a gcc dependency (cleanup included)
RUN apt-get update && apt-get install -yq --no-install-recommends \
    $(cat /opt/gcc_pkgs.txt) \
 && pip3 install -r /opt/requirements_gcc.txt \
 && apt-get purge -y --auto-remove \
    $(cat /opt/gcc_pkgs.txt) \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
# Install jupyter and some necessary python packages
 # tmp hack min-5
 # I'm not installing jupyterlab and I can't update init-actions.sh to not access it
 && mkdir -p /usr/local/share/jupyter/lab \
 # When we upgraded from jupyter 5.7.8 to 6.1.1, we broke terminal button on terra-ui.
 # Hence, make sure to manually test out "launch terminal" button (the button in the green bar next to start and stop buttons)
 # to make sure we don't accidentally break it every time we upgrade notebook version until we figure out an automation test for this
 && pip3 install -r /opt/requirements.txt \
# Copy workspace_cromwell.py script and make it runnable by all users
 && curl -o /usr/local/bin/workspace_cromwell.py \
    https://raw.githubusercontent.com/broadinstitute/cromwhelm/1ceedf89587cffd355f37401b179001f029f77ed/scripts/workspace_cromwell.py \
 && chmod +x /usr/local/bin/workspace_cromwell.py \
# Cromshell 2.0
 && git clone --branch cromshell_2.0 --single-branch \
    https://github.com/broadinstitute/cromshell.git $HOME/cromshell \
 && pip3 install $HOME/cromshell \
 && rm -rf ~/.cache/pip \
 && conda clean -ya

# Utilities
COPY scripts $JUPYTER_HOME/scripts
COPY custom $JUPYTER_HOME/custom
COPY jupyter_notebook_config.py $JUPYTER_HOME

RUN chown -R $USER:users $JUPYTER_HOME \
 && chown -R $USER:users $HOME/.conda \
 && chown -R $USER:users $CONDA_DIR \
 && chown -R $USER:users $HOME/.config/gcloud \
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
