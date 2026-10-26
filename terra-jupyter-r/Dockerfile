FROM us.gcr.io/broad-dsp-gcr-public/terra-jupyter-base:2.1.1

USER root

# terra-jupyter-base 2.0.1 is built on nvidia/cuda:13.4.2-base-ubuntu26.04 (resolute) and already
# installs r-base / r-base-dev from the CRAN resolute-cran40 repo, so this image only adds the
# system libraries R/Bioconductor packages need, the R packages and the R kernel.
#
# Only the R kernel files are copied. Copying all of scripts/ would replace terra-jupyter-base's
# kernelspec.sh, which registers the python3 kernel against the user's conda env.
COPY --chown=jupyter:users scripts/kernel $JUPYTER_KERNEL

# Add env vars to identify binary package installation
ENV TERRA_R_PLATFORM="terra-jupyter-r-3.1.0"
# Please have a look at https://bioconductor.org/developers/release-schedule/
ENV TERRA_R_PLATFORM_BINARY_VERSION=3.23

# Package names verified against Ubuntu 26.04 (resolute).
# Entries that are commented out are kept for reference with the reason they were dropped.
#
# The CRAN repo was set up here with `apt-key adv` and `add-apt-repository`. Neither exists on 26.04
# (apt-key was removed in apt 2.9, software-properties-common is not installed) and the base image
# already writes /etc/apt/sources.list.d/cran.list, so the repo setup is gone.
RUN apt-get update \
    && apt-get install -yq --no-install-recommends \
    libssh2-1-dev \
    libgit2-dev \
    libxml2-dev \
    ## This section installs libraries
    libnetcdf-dev \
    libfftw3-dev \
    libopenbabel-dev \
    libopenmpi-dev \
    libgdal-dev \
    libcairo2-dev \
    # replaces libtiff5-dev (transitional package on 26.04) \
    libtiff-dev \
    # replaces libgsl0-dev, which no longer exists \
    libgsl-dev \
    libgtk2.0-dev \
    # replaces libgl1-mesa-dev (transitional package on 26.04) \
    libgl-dev \
    libglu1-mesa-dev \
    # replaces libgmp3-dev \
    libgmp-dev \
    libxpm-dev \
    libgtkmm-2.4-dev \
    libmpfr-dev \
    libudunits2-dev \
    libmodule-build-perl \
    libapparmor-dev \
    libgeos-dev \
    librdf0-dev \
    libmagick++-dev \
    libsasl2-dev \
    libpoppler-cpp-dev \
    libpq-dev \
    libperl-dev \
    # protobuf 3.21.12, the same version as the protobuf-compiler in terra-jupyter-base \
    libprotobuf-dev \
    ## software - perl extentions and modules
    libarchive-extract-perl \
    libfile-copy-recursive-perl \
    libcgi-pm-perl \
    libdbi-perl \
    libdbd-mysql-perl \
    libxml-simple-perl \
    ## Databases and other software
    # replaces sqlite (SQLite 2), which no longer exists \
    sqlite3 \
    mpi-default-bin \
    openmpi-common \
    imagemagick \
    tabix \
    graphviz \
    jags \
    ## Additional resources
    xfonts-100dpi \
    xfonts-75dpi \
    biber \
    libzmq3-dev \
    libsbml5-dev \
    ## for gpuMagic package
    ocl-icd-opencl-dev \
    ## for ChemmineOB package
    libeigen3-dev \
    ## for rawrr package
    mono-runtime \
    ## for nloptr package
    cmake \
    ## for archive package
    libarchive-dev \
    ## for fs (needed by devtools, tidyverse, shiny, ...) \
    libuv1-dev \
    ## for igraph (needed by Seurat, scran) \
    libglpk-dev \
    ## for keyring (gargle / bigrquery / googledrive) \
    libsecret-1-dev \
    ########## Removed / redundant on Ubuntu 26.04 ##########
    # installed in terra-jupyter-base \
    # apt-utils \
    # libssl-dev \
    # libhdf5-dev \
    # libncurses-dev \
    # r-base-dev \
    # r-base-core \
    # libcurl4-gnutls-dev: conflicts with libcurl4-openssl-dev, which terra-jupyter-base installs \
    # libcurl4-gnutls-dev \
    # apt-transport-https: empty transitional package, https is built into apt \
    # apt-transport-https \
    # libhdf5-serial-dev: no longer exists, libhdf5-dev (in terra-jupyter-base) replaces it \
    # libhdf5-serial-dev \
    # ggobi: removed from Ubuntu \
    # ggobi \
    # libgfortran5: pulled in by r-base-dev (gfortran) \
    # libgfortran5 \
    # libnode-dev: conflicts with the nodesource nodejs in terra-jupyter-base. The V8 R package
    # downloads a static libv8 when it is missing. \
    # libnode-dev \
    #
    # The old `ln -s /usr/lib/gcc/x86_64-linux-gnu/7/libgfortran.so|libstdc++.so` links are dropped: gcc-7
    # is not installed (26.04 ships gcc-15), so they were dangling, and gcc finds both libraries itself.
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# protobuf 3.20.3 was built from source here to match the old deeplearning base image's conda
# protobuf. That image is gone, and terra-jupyter-base ships protoc 3.21.12 from apt, so a
# from-source 3.20.3 in /usr/local would only shadow it. libprotobuf-dev above replaces it.

# DEVEL: Add sys env variables to DEVEL image
# Variables in Renviron.site are made available inside of R.
# Add libsbml CFLAGS
ENV LIBSBML_CFLAGS="-I/usr/include"
ENV LIBSBML_LIBS="-lsbml"
RUN echo 'export LIBSBML_CFLAGS="-I/usr/include"' >> /etc/profile \
    && echo 'export LIBSBML_LIBS="-lsbml"' >> /etc/profile

# Extract package tarballs with R's internal untar instead of GNU tar. GNU tar 1.35 on 26.04 fails
# with "Cannot open: Function not implemented" when the amd64 image is built under emulation on
# Apple Silicon (e.g. on GitHub tarballs installed through remotes, such as DataBiosphere/Ronaldo).
# TAR is read by utils::untar() (used by remotes / BiocManager), R_INSTALL_TAR by R CMD INSTALL.
# ARG, so they only apply to the build and users keep the default tar.
ARG TAR=internal
ARG R_INSTALL_TAR=internal

## set pip3 to run as root, not as jupyter user
ENV PIP_USER=false

## Install python packages needed for a few Bioc packages
# Ubuntu 26.04 has no system pip (terra-jupyter-base drops python3-pip, and PEP 668 blocks it anyway),
# so install cwltool into the user's conda env and link it onto the default PATH for R to find.
RUN $CONDA_ENV_HOME/bin/python -m pip install --no-cache-dir --root-user-action=ignore cwltool \
    && ln -s $CONDA_ENV_HOME/bin/cwltool /usr/local/bin/cwltool \
    && cwltool --version \
    # chown only what pip added: a chown -R would copy the whole env into this layer
    && find $CONDA_ENV_HOME ! -user $USER -exec chown -h $USER:users {} +

RUN R -e 'install.packages("BiocManager")' \
    ## check version
    && R -e "BiocManager::install(version='$TERRA_R_PLATFORM_BINARY_VERSION', ask=FALSE)" \
    && R -e 'BiocManager::install(c( \
    "boot", \
    "class", \
    "cluster", \
    "codetools", \
    "foreign", \
    "kernsmooth", \
    "lattice", \
    "mass", \
    "Matrix", \
    "mgcv", \
    "nlme", \
    "nnet", \
    "rpart", \
    "Seurat", \
    "spatial", \
    "survival", \
    # Jupyter notebook essentials
    "IRdisplay",  \
    "IRkernel", \
    # GCP essentials
    "bigrquery",  \
    "googleCloudStorageR", \
    # User oriented packages
    "reticulate", \
    "remotes", \
    "devtools", \
    "tidyverse", \
    "pbdZMQ", \
    "uuid"))' \
    && R -e 'BiocManager::install("DataBiosphere/Ronaldo")'

# Install Bioconductor packages found at:
# https://raw.githubusercontent.com/anvilproject/anvil-docker/master/anvil-rstudio-bioconductor/install.R
# This has moved to https://github.com/anvilproject/anvil-docker/blob/main/anvil-rstudio-bioconductor/info/anvil-rstudio-bioconductor-3.21.0-versions.json#L92
RUN R -e 'BiocManager::install(c( \
    "AnVIL", \
    "SingleCellExperiment", \
    "GenomicFeatures", \
    "GenomicAlignments", \
    "ShortRead", \
    "DESeq2", \
    "AnnotationHub", \
    "ExperimentHub", \
    "ensembldb", \
    "scRNAseq", \
    "scran", \
    "Rtsne"))'

## pip runs as jupyter user
ENV PIP_USER=true

# Register the R kernel ("ir", the name Terra R notebooks use) now that IRkernel is installed.
# installspec() puts the logos and kernel.json in $JUPYTER_KERNELSPEC_DIR/kernels/ir, then
# kernelspec.sh replaces kernel.json with one that starts R through kernel_bootstrap.sh.
RUN R -e 'IRkernel::installspec(user=FALSE)' \
    && chmod +x $JUPYTER_KERNEL/r_kernelspec.sh \
    && $JUPYTER_KERNEL/r_kernelspec.sh $JUPYTER_KERNEL $JUPYTER_KERNELSPEC_DIR/kernels \
    && chown -R $USER:users /usr/local/lib/R/site-library $JUPYTER_KERNELSPEC_DIR /home/jupyter

USER $USER
