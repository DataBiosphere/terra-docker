# `terra-base` image: (soon to be removed) merged with into terra-jupyter-base
# package list, on the latest gpu-enabled base image on Ubuntu 26.
ARG BASE_PLATFORM=linux/amd64
# ARG BASE_PLATFORM=linux/amd64
FROM --platform=${BASE_PLATFORM} nvidia/cuda:13.4.3-base-ubuntu26.04

# want the command to fail due to an error at any stage in the pipe: https://github.com/hadolint/hadolint/wiki/DL4006
SHELL ["/usr/bin/bash", "-o", "pipefail", "-c"]

#######################
# General Environment Variables
#######################
ENV DEBIAN_FRONTEND=noninteractive
# LC_ALL is set after the prerequisites step below, once locale-gen has generated en_US.UTF-8

# Version of python to be installed and used (conda base, the jupyter server venv and the user's
# conda env). 3.13 rather than 3.14: tensorflow and several scientific packages the child images
# install have no Python 3.14 wheels yet. Ubuntu 26.04's own /usr/bin/python3 stays at 3.14.
# NOTE TensorFlow only supports up to python 3.13
ENV PYTHON_VERSION=3.13
# Paired conda installer
# See https://repo.anaconda.com/miniconda/ for list of miniconda
ENV CONDA_INSTALLER=https://repo.anaconda.com/miniconda/Miniconda3-py313_26.9.4-0-Linux-x86_64.sh
ENV JUPYTER_VERSION=7.6.3
ENV JUPYTER_PORT=8000
ENV NODE_MAJOR=26
# Minimum Node release; the build fails if nodesource installs anything older
ENV NODE_MIN_VERSION=26.12.1

USER root

#################
# Install Prerequisites
#################
# terra-base prerequisites + the packages terra-jupyter-base added on top (carried over from the
# old deeplearning image), installed in a single layer.
# Package names verified against Ubuntu 26.04 (resolute) + the CUDA 13.4 repo.
# Entries that are commented out are kept for reference with the reason they were dropped;
# "pulled in by X" means apt still installs it as a dependency of X, so listing it is redundant
# and only pins a soname that breaks on the next Ubuntu release.
#
# The nvidia/cuda Ubuntu base is a minimized image: /etc/dpkg/dpkg.cfg.d/excludes drops every man
# page and /usr/bin/man is diverted to a stub. That makes man-db (below) useless and makes
# update-alternatives warn "skip creation of /usr/share/man/man1/lzma.1.gz ..." for every
# alternative that links a man page. Re-enable man pages before installing (the same thing
# Ubuntu's `unminimize` does for man pages, without restoring all of /usr/share/doc).
RUN sed -i '\|^path-exclude=/usr/share/man/\*|d' /etc/dpkg/dpkg.cfg.d/excludes \
    && if [ "$(dpkg-divert --truename /usr/bin/man)" = "/usr/bin/man.REAL" ]; then \
         rm -f /usr/bin/man && dpkg-divert --quiet --remove --rename /usr/bin/man; \
       fi \
    && apt-get update && apt-get install -yq --no-install-recommends \
    # basic necessities \
    sudo \
    ca-certificates \
    curl \
    jq \
    # gnupg requirement \
    gnupg \
    dirmngr \
    # useful utilities for debugging within docker itself \
    nano \
    less \
    procps \
    lsb-release \
    # gcc compiler (gcc-15 on Ubuntu 26.04) \
    build-essential \
    locales \
    # for ssh-agent and ssh-add \
    keychain \
    # extras \
    wget \
    bzip2 \
    git \
    ########## terra-jupyter-base ########## \
    # debugging / terminal utilities \
    htop \
    tree \
    rsync \
    screen \
    tmux \
    # tmux/screen utmp helper (only a Recommends, so list it explicitly) \
    libutempter0 \
    dialog \
    bsdextrautils \
    inotify-tools \
    pciutils \
    man-db \
    apt-utils \
    pkg-config \
    llvm \
    # editors \
    emacs \
    vim \
    # xxd is no longer a dependency of vim on 26.04, keep it explicitly \
    xxd \
    # Python build headers \
    zlib1g-dev \
    libssl-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    # replaces libncurses5-dev / libncursesw5-dev, which no longer exist \
    libncurses-dev \
    tk-dev \
    libffi-dev \
    liblzma-dev \
    libcurl4-openssl-dev \
    # System python3 (3.13 on Ubuntu 26.04) helpers. Users should use the conda env. \
    python3-setuptools \
    python3-snappy \
    python3-tk \
    python3-wheel \
    # RDMA / InfiniBand userspace for multi-GPU networking (only Recommends, so list explicitly) \
    libibverbs1 \
    libnl-3-200 \
    libnl-genl-3-200 \
    libnl-route-3-200 \
    # Java (OpenJDK 25 on Ubuntu 26.04) \
    default-jdk \
    # scientific / data libraries \
    libhdf5-dev \
    libnuma-dev \
    libopenblas0 \
    libopenblas0-pthread \
    libsnappy-dev \
    protobuf-compiler \
    # FUSE: libfuse2t64 for legacy fuse2 binaries/AppImages, fuse3 for the userspace tools \
    fuse3 \
    libfuse2t64 \
    # docs / LaTeX for nbconvert PDF export \
    pandoc \
    texlive \
    texlive-fonts-recommended \
    texlive-latex-base \
    texlive-latex-recommended \
    # LuaJITTeX engine (only a Recommends of texlive-binaries) \
    libtexluajit2 \
    # Tk BLT extension \
    blt \
    # misc runtime libraries used by the old deeplearning image \
    libgd3 \
    libjansson4 \
    libsodium23 \
    libuchardet0 \
    m17n-db \
    ########## Removed / redundant on Ubuntu 26.04 ##########
    # TensorRT: on CUDA 13.4 libnvinfer11 alone is 2.5GB installed (2.6GB with the plugin and python
    # bindings), which takes the image from ~4.5GB to ~7GB. Nothing in this image uses it, and GPU
    # frameworks (tensorflow, torch) ship their own TensorRT/CUDA libraries via pip.
    # Was libnvinfer8 / libnvinfer-plugin8 on Ubuntu 22.04.
    # libnvinfer11 \
    # libnvinfer-plugin11 \
    # python3-libnvinfer \
    # python3-pip: Ubuntu's pip 25.1.1 vendors urllib3 1.26.20 (GHSA-vxq7-64xx-v4gw, GHSA-8988-9cw3-xx77,
    # GHSA-qccp-gfcp-xxvc, GHSA-38jv-5279-wg99). PEP 668 blocks it from installing into the system
    # python anyway; users get pip from the conda env and uv manages the jupyter server env.
    # python3-pip \
    # python3-openssl: it is the only package that pulls in Ubuntu's python3-cryptography 46.0.5 (GHSA-537c-gmf6-5ccf,
    # GHSA-jwv3-5hgf-82ww, GHSA-g6cj-pr64-35w5, fixed in 50.0.0). Like python3-pip, nothing uses the system python;
    # the conda env has pyopenssl/cryptography for notebooks.
    # python3-openssl \
    # python3-distutils / python3-lib2to3: removed from Python in 3.12 / 3.13, no packages on 26.04 \
    # python3-distutils \
    # python3-lib2to3 \
    # libopenblas-base: transitional package dropped after Ubuntu 22.04, libopenblas0 replaces it \
    # libopenblas-base \
    # checkinstall: was only used to build python from source; python now comes from conda/uv \
    # checkinstall \
    # apt-transport-https: empty transitional package, https is built into apt >= 1.5 (26.04 ships apt 3.2) \
    # apt-transport-https \
    # gcc-12 toolchain: 26.04 defaults to gcc-15 via build-essential; gcc-12 was pinned for Ubuntu 22.04 \
    # cpp-12 \
    # gcc-12 \
    # libgcc-12-dev \
    # dkms / kmod / dctrl-tools: build/load kernel modules, which cannot be done from inside a container \
    # dkms \
    # dctrl-tools \
    # kmod \
    # fuse: on 26.04 this is the fuse3 package (3.18), replaced by the explicit fuse3 entry above \
    # fuse \
    # default-jre: pulled in by default-jdk \
    # default-jre \
    # libcmark-gfm*: pandoc 3.x on 26.04 no longer links against the system cmark-gfm \
    # libcmark-gfm-extensions0.29.0.gfm.3 \
    # libcmark-gfm0.29.0.gfm.3 \
    # pulled in by emacs \
    # emacs-bin-common \
    # emacs-common \
    # emacs-gtk \
    # emacsen-common \
    # libgpm2 \
    # libm17n-0 \
    # libotf1 \
    # pulled in by vim \
    # vim-common \
    # vim-runtime \
    # pulled in by pandoc \
    # pandoc-data \
    # pulled in by texlive \
    # texlive-base \
    # texlive-binaries \
    # tex-common \
    # t1utils \
    # fonts-lmodern \
    # libkpathsea6 \
    # libptexenc1 \
    # libsynctex2 \
    # libteckit0 \
    # libtexlua53 \
    # libzzip-0-13 \
    # pulled in by libhdf5-dev (hdf5 1.14.6, soname 310; was 103-1 / 100 / 102 on 22.04) \
    # hdf5-helpers \
    # libaec-dev \
    # libaec0 \
    # libsz2 \
    # libhdf5-103-1 \
    # libhdf5-cpp-103-1 \
    # libhdf5-fortran-102 \
    # libhdf5-hl-100 \
    # libhdf5-hl-cpp-100 \
    # libhdf5-hl-fortran-100 \
    # pulled in by protobuf-compiler (protobuf 3.21.12, libprotobuf32t64; was libprotobuf23 on 22.04) \
    # libprotobuf23 \
    # libprotoc23 \
    # pulled in by libsnappy-dev / libnuma-dev / pciutils / inotify-tools / tmux \
    # libsnappy1v5 \
    # libnuma1 \
    # libpci3 \
    # pci.ids \
    # libinotifytools0 \
    # libevent-core-2.1-7 \
    # pulled in by man-db \
    # groff-base \
    # libpipeline1 \
    # install-info \
    # pulled in by blt \
    # tk8.6-blt2.5 \
    # pulled in by build-essential (gcc-15 sanitizer runtimes) \
    # libasan8 \
    # libtsan2 \
    # pulled in by python3 / python3-tk (libpython3.14 on 26.04) \
    # libpython3.10 \
    # libpopt0: pulled in by rsync \
    # libpopt0 \
    #
    # Uncomment en_US.UTF-8 for inclusion in generation
    && sed -i 's/^# *\(en_US.UTF-8\)/\1/' /etc/locale.gen \
    # Generate locale
    && locale-gen \
    # The ubuntu:26.04 base ships Canonical's pebble service manager (/usr/bin/pebble, not owned by any
    # package). Nothing here uses it, and it is built with Go 1.26.7 (GO-2026-6601..6613, GO-2026-6617, fixed in 1.26.9).
    && rm -rf /usr/bin/pebble /var/lib/pebble \
    # cleanup
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set only after locale-gen above: setting it earlier makes perl (debconf) warn
# "Setting locale failed" during the apt install, before en_US.UTF-8 exists.
ENV LC_ALL=en_US.UTF-8

##############################
# Install the Google Cloud CLI
##############################
# Provides gcloud, gsutil and bq. The previous base image
# (gcr.io/deeplearning-platform-release/*) shipped these pre-installed; the
# nvidia/cuda base does not, so install them explicitly (~0.9GB).
#
# The apt package ships its own bundled Python, so it is independent of the
# system interpreter and of both of the image's Python environments.
# Note: it also bundles its own urllib3 copies (in lib/third_party, gsutil and bq) that image
# scanners may flag; those can only be updated by a newer google-cloud-cli release.
#
# google-cloud-cli also bundles:
# - cryptography 46.0.7 in its python (GHSA-537c-gmf6-5ccf, GHSA-jwv3-5hgf-82ww, GHSA-g6cj-pr64-35w5, fixed in
#   50.0.0). Upgrade it along with pyopenssl, whose 26.0.0 pins cryptography<47 (26.4.0 allows <51).
# - gcloud-crc32c, a Go 1.26.6 binary (GO-2026-6601..6613, GO-2026-6617, fixed in 1.26.9). It is an optional speed-up:
#   without it `gcloud storage` hashes with the bundled google_crc32c C extension instead.
# Remove both once a google-cloud-cli release ships the fixed versions.
ENV GCLOUD_PYTHON=/usr/lib/google-cloud-sdk/platform/bundledpythonunix/bin/python3
RUN curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg \
          | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg \
    # "cloud-sdk" is the name of Google's apt repository (it still serves google-cloud-cli), keep it as is
    && echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" \
         > /etc/apt/sources.list.d/google-cloud-cli.list \
    && apt-get update \
    && apt-get install -yq --no-install-recommends google-cloud-cli \
    && $GCLOUD_PYTHON -m pip install --no-cache-dir --root-user-action=ignore --upgrade "cryptography>=50.0.0" "pyopenssl>=26.4.0" \
    && $GCLOUD_PYTHON -c "import OpenSSL, google_crc32c, cryptography; assert int(cryptography.__version__.split('.')[0]) >= 50" \
    && rm -f /usr/lib/google-cloud-sdk/bin/gcloud-crc32c \
    && gcloud --version \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

##############################
# Set up Node for Jupyterlab
##############################
# The Google Cloud apt key that terra-base imported here is now installed with google-cloud-cli above.

# Install Node >18
# Empty install (no packages listed) in terra-base, it only refreshed the apt index.
# RUN apt-get update && apt-get install -yq --no-install-recommends
# Ubuntu 22.04 shipped a libnode-dev that conflicted with the nodesource nodejs package.
# The 26.04 base image does not include it, so this removal is a no-op.
# RUN dpkg --remove --force-remove-reinstreq libnode-dev
RUN mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" > /etc/apt/sources.list.d/nodesource.list \
    && apt-get update \
    && apt-get install -yq --no-install-recommends nodejs \
    && dpkg --compare-versions "$(node --version | sed 's/^v//')" ge "$NODE_MIN_VERSION" \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# npm (11.20.0 from nodesource) bundles vulnerable copies of these dependencies. Swap
# each one for the first fixed release in the range npm requires:
# - http-cache-semantics 4.2.0 -> 4.3.0: CVE-2026-93748 / GHSA-ch52-4w7c-c8xp (make-fetch-happen wants ^4.1.1)
# - brace-expansion 5.0.9 -> 5.0.12: GHSA-qhr7-859c-m2p7, GHSA-6j4f-fj2g-mc7p (minimatch wants ^5.0.5; its only
#   dependency, balanced-match ^4.0.2, is already bundled at 4.0.4)
# - undici 6.28.0 -> 6.29.1: CVE-2026-19534 / GHSA-rfgv-xxqx-mfg5 (node-gyp wants ^6.25.0). Node's own built-in
#   undici (8.11.2) is already fixed.
# Remove an entry once nodesource ships an npm with the fixed version.
# Each package is installed into a scratch prefix and only its own directory is copied over npm's copy. npm extracts
# the tarball itself: GNU tar fails with "Function not implemented" on tarballs with nested directories (e.g.
# brace-expansion's dist/) when the amd64 image is built under emulation on Apple Silicon.
ENV NPM_PATCHES="http-cache-semantics@4.3.0 brace-expansion@5.0.12 undici@6.29.1"
RUN NPM_MODULES=$(npm root -g)/npm/node_modules \
    && for PKG in $NPM_PATCHES; do \
         NAME=${PKG%@*} && VERSION=${PKG##*@} && DEST=$NPM_MODULES/$NAME \
         && test -d $DEST \
         && npm install --silent --no-save --no-package-lock --ignore-scripts --omit=dev --prefix /tmp/npm-patch $PKG \
         && rm -rf $DEST \
         && cp -r /tmp/npm-patch/node_modules/$NAME $DEST \
         && test "$(node -p "require('$DEST/package.json').version")" = "$VERSION" \
         || exit 1; \
       done \
    && rm -rf /tmp/npm-patch \
    && npm cache clean --force \
    && npm --version

##########################
# Create the User's Jupyter User
##########################
# Create the jupyter user and give sudo permission
ENV USER=jupyter
# This UID must stay static to be one greater than the welder user (1001)
ENV USER_UID=1002

# Create the user home and add to the users group
ENV USER_HOME=/home/$USER
RUN useradd -m -s /bin/bash -d $USER_HOME -N -u $USER_UID  $USER \
    && usermod -g users $USER

# We want to grant the user sudo permissions without password
 # so they can install the necessary packages that they want to use on the docker container
RUN echo "$USER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$USER \
    && chmod 0440 /etc/sudoers.d/$USER

############
# Install R
############
# add R repo for later R package installation
# software-properties-common (add-apt-repository) is not needed: the CRAN repo (resolute-cran40)
# is written to sources.list.d directly. r-base was also installed twice in terra-base.
# r-base-dev pulls in gfortran. On Ubuntu 26.04 its gfortran.1.gz is a dangling link to
# gfortran-15.1.gz (the page is shipped as x86_64-linux-gnu-gfortran-15.1.gz), which makes
# update-alternatives warn "skip creation of /usr/share/man/man1/f77.1.gz / f95.1.gz" and breaks
# `man gfortran`. Create the missing link first so the f77/f95 man page alternatives are set up.
RUN ln -sf x86_64-linux-gnu-gfortran-15.1.gz /usr/share/man/man1/gfortran-15.1.gz \
    && curl -fsSL https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc -o /usr/share/keyrings/cran.asc \
    && echo "deb [signed-by=/usr/share/keyrings/cran.asc] https://cloud.r-project.org/bin/linux/ubuntu $(. /etc/os-release && echo $VERSION_CODENAME)-cran40/" > /etc/apt/sources.list.d/cran.list \
    && apt-get update \
    && apt-get install -yq --no-install-recommends r-base r-base-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

############################################
# Install Miniconda and setup base conda environment
############################################
## CONDA should not be used by devs to manage package dependencies,
# but is a widely used tool to manage python environments in a runtime
 # and we should provide it to users

# download and install conda
ENV CONDA_HOME=/opt/conda
# Don't print Anaconda's "defaults" channel notices (e.g. "Anaconda will stop building new Python 3.10
# packages") in the build log. They are announcements for all channel users, not about this image,
# which only uses python 3.13. An ARG is only set during the build, so users still see notices.
ARG CONDA_NUMBER_CHANNEL_NOTICES=0
# ENV PATH="${PATH}:${CONDA_ENV_HOME}/bin:${CONDA_HOME}/bin"
ENV PATH="${PATH}:${CONDA_HOME}/bin"

# Install, patch, clean and chown in ONE layer. A `conda clean` or `chown -R` in a later RUN does
# not shrink this layer, it writes a second full copy of /opt/conda on top of it (~0.4GB for the
# installer's package cache, ~0.6GB for the chown).
# - conda tos: have to accept the conda terms of service to be able to install packages
# - the Miniconda installer ships these vulnerable packages in the base env:
#   - urllib3 2.7.0 (GHSA-vxq7-64xx-v4gw, GHSA-8988-9cw3-xx77, fixed in 2.8.0)
#   - anyio 4.12.1 (GHSA-82r6-8w77-94w6, fixed in 4.14.2)
#   - pyjwt 2.13.0 (GHSA-ffc3-869f-jxw9, GHSA-w2cx-738m-mc7w, GHSA-r6x4-923q-g947, GHSA-p4g4-x82p-q773,
#     GHSA-9v7f-9g4p-ffgj, GHSA-9j54-fg26-wv3r, fixed in 2.14.0)
RUN curl -so $HOME/miniconda.sh $CONDA_INSTALLER \
    && chmod +x $HOME/miniconda.sh \
    && $HOME/miniconda.sh -b -p $CONDA_HOME \
    && rm $HOME/miniconda.sh \
    && conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main \
    && conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r \
    && conda install -n base -y "urllib3>=2.8.0" "anyio>=4.14.2" "pyjwt>=2.14.0" "cryptography>=50.0.0" \
    && conda clean -afy \
    && chown -R $USER:users $CONDA_HOME

# In order to override the default kernel, the conda environment must be named 'python3'
ENV CONDA_ENV_NAME=python3
# The env must live OUTSIDE /home/jupyter: Leonardo mounts the runtime's persistent disk over the
# notebooks dir (jupyter-docker-compose-gce.yaml: "/mnt/disks/work:${NOTEBOOKS_DIR}", NOTEBOOKS_DIR=/home/jupyter),
# which hides anything the image puts there. With the env at /home/jupyter/.envs/python3 every kernel died
# on Terra with "/home/jupyter/.envs/python3/bin/python: No such file or directory".
# $CONDA_HOME/envs is conda's standard envs dir, so `conda activate python3` also finds it by name.
# ENV CONDA_ENV_HOME=$USER_HOME/.envs/$CONDA_ENV_NAME
ENV CONDA_ENV_HOME=$CONDA_HOME/envs/$CONDA_ENV_NAME
ENV CONDA_FILES=$CONDA_HOME/custom

# Copy over the conda environment files
COPY --chown=jupyter:users conda/ $CONDA_FILES

# Set up the path to the user python from conda
ENV BASE_PYTHON_PATH=$CONDA_HOME/bin/python$PYTHON_VERSION
# Tell conda to NOT write bite code (aka these.pyc files)
ENV PYTHONDONTWRITEBYTECODE=true

# Create the conda environment that will be used by the jupyter user.
#
# Then upgrade urllib3 in it for GHSA-vxq7-64xx-v4gw, GHSA-8988-9cw3-xx77, GHSA-qccp-gfcp-xxvc and
# GHSA-38jv-5279-wg99 (fixed in urllib3 2.8.0, no 1.26.x backport). The env otherwise resolves to
# urllib3 1.26.20 because getm 0.0.5 (a terra-notebook-utils dependency with no newer release) pins
# requests<2.30, and requests<2.30 pins urllib3<1.27. getm and terra-notebook-utils both pass
# Retry(method_whitelist=...), which urllib3 2.x removed; rename it to allowed_methods (available
# since urllib3 1.26) so they import on 2.x. --no-deps skips pip's resolver, so it does not report
# getm's requests<2.30 pin as a conflict; requests' other dependencies (charset-normalizer, idna,
# certifi) are already installed at compatible versions, and the import check below verifies it.
# --root-user-action=ignore: installing into the env as root during the build is intended.
# Remove the patch once getm / terra-notebook-utils publish urllib3 2 compatible releases.
RUN conda env create --prefix $CONDA_ENV_HOME --file $CONDA_FILES/conda-environment.yaml \
    && SITE_PACKAGES=$($CONDA_ENV_HOME/bin/python -c "import sysconfig; print(sysconfig.get_paths()['purelib'])") \
    && sed -i 's/method_whitelist=/allowed_methods=/' \
         $SITE_PACKAGES/getm/http.py \
         $SITE_PACKAGES/terra_notebook_utils/table.py \
    && ! grep -rq "method_whitelist" --include='*.py' $SITE_PACKAGES/getm $SITE_PACKAGES/terra_notebook_utils \
    && $CONDA_ENV_HOME/bin/python -m pip install --no-cache-dir --no-deps --root-user-action=ignore --upgrade "urllib3>=2.8.0" "requests>=2.32.4" \
    && $CONDA_ENV_HOME/bin/python -c "import urllib3, requests, getm.http, terra_notebook_utils.table, firecloud.api; assert int(urllib3.__version__.split('.')[0]) >= 2" \
    # Register the conda env as the 'python3' kernel
    && $CONDA_ENV_HOME/bin/python -m ipykernel install --name=$CONDA_ENV_NAME \
    # Remove packages tarballs and python bytecode files from the image
    && conda clean -afy \
    && rm $CONDA_FILES/conda-environment.yaml \
    # Make sure the USER owns the env (created as root after /opt/conda was chowned above)
    && chown -R $USER:users $CONDA_ENV_HOME

##############################
# Setup UV Environment for Jupyter
##############################
# Using UV (Universal Virtualenv) to create a virtual environment
# UV is used in place of poetry for speed and simplicity.

# NOTE: this is for the environment the jupyter server will be running in,
# separate from the jupyter user's conda environment.
COPY uv.lock .
COPY pyproject.toml .

# Setup UV environment variables
# - tells uv to copy the Python files into the container from the cache mount,
# - tell uv to byte-compile packages for faster application startups,
# - don't seed venv, we need to install separately
# - don't cache to keep the image size small
ENV UV_LINK_MODE=copy \
    UV_COMPILE_BYTECODE=1 \
    UV_VENV_SEED=false \
    UV_NO_CACHE=true

# Download the latest installer
ADD https://astral.sh/uv/install.sh /uv-installer.sh
RUN sh /uv-installer.sh && rm /uv-installer.sh

# Add local bin to PATH for uv
ENV PATH="/root/.local/bin/:$PATH"

ENV JUPYTER_HOME=/etc/jupyter
ENV UNDERSCORE_VERSION=1.13.8

# Create a virtual environment and install jupyter packages
# setuptools and wheel are required for some of the jupyter extensions
# chown in the same layer for the same reason as /opt/conda above.
RUN uv venv $JUPYTER_HOME --python $BASE_PYTHON_PATH \
    && source $JUPYTER_HOME/bin/activate \
    && uv pip install wheel \
    && uv pip install setuptools \
    && uv pip install -r pyproject.toml --no-cache --no-build-isolation \
    # GHSA-v638-q856-grg8 / CVE-2023-39663: nbclassic bundles MathJax 2.7.9, and no MathJax 2.x release
    # fixes it. Delete it in this layer, so no layer of the image contains it. jupyter_server_config.py
    # sets c.NotebookApp.enable_mathjax = False so the classic UI does not request the missing files.
    # Notebook 7 and JupyterLab are unaffected: they bundle MathJax 3 (mathjax-full 3.2.2).
    && rm -rf $JUPYTER_HOME/lib/python$PYTHON_VERSION/site-packages/nbclassic/static/components/MathJax \
    && ! find $JUPYTER_HOME -name MathJax.js | grep -q . \
    # GHSA-qpx9-hpmf-5gmw: nbclassic 1.3.3 (the latest) bundles underscore 1.13.7, fixed in 1.13.8 (a patch release
    # with the same API). Replace the copy in static/components, which is the one with a package.json that scanners
    # match. Remove this once nbclassic ships underscore >= 1.13.8.
    # Installed with npm rather than extracted with tar, for the reason given at the npm patches above.
    && NBC_UNDERSCORE=$JUPYTER_HOME/lib/python$PYTHON_VERSION/site-packages/nbclassic/static/components/underscore \
    && npm install --silent --no-save --no-package-lock --ignore-scripts --prefix /tmp/underscore underscore@$UNDERSCORE_VERSION \
    && rm -rf $NBC_UNDERSCORE && mkdir -p $NBC_UNDERSCORE \
    && cp -r /tmp/underscore/node_modules/underscore/{package.json,README.md,LICENSE,underscore-min.js,underscore-min.js.map,modules} $NBC_UNDERSCORE/ \
    && rm -rf /tmp/underscore && npm cache clean --force \
    && test "$(node -p "require('$NBC_UNDERSCORE/package.json').version")" = "$UNDERSCORE_VERSION" \
    # Remove default jupyter kernel (to force use of the conda python kernel)
    && $JUPYTER_HOME/bin/jupyter kernelspec remove python3 -y \
    # Cleanup
    && rm uv.lock pyproject.toml \
    && chown -R $USER:users $JUPYTER_HOME

# add jupyter to path
ENV PATH="${PATH}:${JUPYTER_HOME}/bin"

# #######################
# # Terra-specific Utilities
# ####################### \

# Copy over utility scripts and config files
ENV JUPYTER_SCRIPTS=$JUPYTER_HOME/scripts
ENV JUPYTER_CUSTOM=$JUPYTER_HOME/custom
ENV JUPYTER_EXTENSIONS=$JUPYTER_SCRIPTS/extension
ENV JUPYTER_KERNEL=$JUPYTER_SCRIPTS/kernel

COPY --chown=jupyter:users scripts $JUPYTER_HOME/scripts
COPY --chown=jupyter:users custom $JUPYTER_HOME/custom
COPY --chown=jupyter:users jupyter_server_config.py $JUPYTER_HOME
# Settings-free placeholder: Leonardo's init script still runs `sed -i ... /etc/jupyter/jupyter_notebook_config.py`
# and aborts the runtime startup if the file is missing. See the comments in the file.
COPY --chown=jupyter:users jupyter_notebook_config.py $JUPYTER_HOME

# Put the custom modules on the jupyter server's import path. jupyter_server_config.py
# refers to jupyter_delocalize and jupyter_localize_extension by module name, and neither
# is pip-installed, so without this the server fails at startup with
# "could not be imported". A .pth scopes the path to this venv only, leaving the user's
# conda kernel untouched (which a global PYTHONPATH would not).
#
# Ownership of $JUPYTER_HOME and $CONDA_HOME is set when they are created; terra-base's
# `chown -R $JUPYTER_HOME $CONDA_HOME` here duplicated both trees (~0.9GB) into a new layer.
# Only fix up anything still not owned by the user, and make the scripts executable.
RUN echo "$JUPYTER_CUSTOM" > $JUPYTER_HOME/lib/python$PYTHON_VERSION/site-packages/terra-custom.pth \
    && find $JUPYTER_HOME $CONDA_HOME ! -user $USER -exec chown -h $USER:users {} + \
    && find $JUPYTER_EXTENSIONS $JUPYTER_KERNEL -name '*.sh' -type f -exec chmod +x {} + \
    && chmod +x $JUPYTER_SCRIPTS/run-jupyter.sh

# Setup the jupyter (python3) kernel. The R kernel is registered by terra-jupyter-r after it installs IRkernel.
ENV JUPYTER_KERNELSPEC_DIR=/usr/local/share/jupyter/
RUN chown -R $USER:users $JUPYTER_KERNELSPEC_DIR \
    # You can get kernel directory by running `jupyter kernelspec list`
    && $JUPYTER_KERNEL/kernelspec.sh $JUPYTER_KERNEL $JUPYTER_KERNELSPEC_DIR/kernels

# Create the welder user
# The welder uid is consistent with the Welder docker definition here:
#  https://github.com/DataBiosphere/welder/blob/master/project/Settings.scala
# Adding welder-user to the Jupyter container isn't strictly required, but it makes welder-added
# files display nicer when viewed in a terminal.
ENV WELDER_USER=welder-user
# This UID must stay consistent with the UID defined in Welder
ENV WELDER_UID=1001
RUN useradd -m -s /bin/bash -N -u $WELDER_UID $WELDER_USER

# Add an empty file to indicate that this is a terra-base image with a separate jupyer server environment
# Need a flag to check in the startup scripts to know whether to use the conda environment jupyter
RUN touch /etc/jupyter/.terra-base-marker

# Make sure that the jupyter user will have access to the jupyter path in the working directory
EXPOSE $JUPYTER_PORT
WORKDIR $USER_HOME

# make pip install to a user directory, instead of a system directory which requires root.
# this is useful so `pip install` commands can be run in the context of a notebook.
ENV PIP_USER=true
USER $USER

# Note: this entrypoint is provided for running Jupyter independently of Leonardo.
# When Leonardo deploys this image onto a cluster, the entrypoint is overwritten to enable
# additional setup inside the container before execution.  Jupyter execution occurs when the
# init-actions.sh script uses 'docker exec' to call run-jupyter.sh.
ENTRYPOINT ["/etc/jupyter/bin/jupyter", "notebook"]
