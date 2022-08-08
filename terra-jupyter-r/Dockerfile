FROM us.gcr.io/broad-dsp-gcr-public/terra-jupyter-base:1.0.11
USER root

COPY scripts $JUPYTER_HOME/scripts

# Add env vars to identify binary package installation
ENV TERRA_R_PLATFORM="terra-jupyter-r"
ENV TERRA_R_PLATFORM_BINARY_VERSION=3.15.0

# Install protobuf 3.19.1. Note this version comes from base deep learning image. Use `conda list` to see what's installed
RUN cd /tmp \
  && wget https://github.com/protocolbuffers/protobuf/releases/download/v3.19.1/protobuf-all-3.19.1.tar.gz \
	&& tar -xvzf protobuf-all-3.19.1.tar.gz \
	&& cd protobuf-3.19.1/ \
	&& ./configure \
	&& make \
	&& make check \
	&& sudo make install \
	&& sudo ldconfig \
	&& rm -rf /tmp/protobuf-* \
	&& cd ~

# Add R kernel
RUN find $JUPYTER_HOME/scripts -name '*.sh' -type f | xargs chmod +x \
 && $JUPYTER_HOME/scripts/kernel/kernelspec.sh $JUPYTER_HOME/scripts/kernel /opt/conda/share/jupyter/kernels

# https://cran.r-project.org/bin/linux/ubuntu/README.html
RUN apt-get update \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9 \
    && add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran40/' \
    && apt-get install -yq --no-install-recommends apt-transport-https \
    && apt update \
    && apt install -yq --no-install-recommends \
	apt-utils \
	libssh2-1-dev \
	libssl-dev \
	libcurl4-gnutls-dev \
	libgit2-dev \
	libxml2-dev \
	libgfortran-7-dev \
	r-base-dev \
	r-base-core \
	## This section installs libraries
	libnetcdf-dev \
	libhdf5-serial-dev \
	libfftw3-dev \
	libopenbabel-dev \
	libopenmpi-dev \
	libexempi3 \
	libgdal-dev \
	libcairo2-dev \
	libtiff5-dev \
	libgsl0-dev \
	libgtk2.0-dev \
	libgl1-mesa-dev \
	libglu1-mesa-dev \
	libgmp3-dev \
	libhdf5-dev \
	libncurses-dev \
	libxpm-dev \
	libv8-3.14-dev \
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
	libgfortran5 \
	## software - perl extentions and modules
	libarchive-extract-perl \
	libfile-copy-recursive-perl \
	libcgi-pm-perl \
	libdbi-perl \
	libdbd-mysql-perl \
	libxml-simple-perl \
	## Databases and other software
	sqlite \
	mpi-default-bin \
	openmpi-common \
	tcl8.5-dev \
	imagemagick \
	tabix \
	ggobi \
	graphviz \
	jags \
	## Additional resources
	xfonts-100dpi \
	xfonts-75dpi \
	biber \
	libzmq3-dev \
	libsbml5-dev \
	biber \
    && ln -s /usr/lib/gcc/x86_64-linux-gnu/7/libgfortran.so /usr/lib/x86_64-linux-gnu/libgfortran.so \
    && ln -s /usr/lib/gcc/x86_64-linux-gnu/7/libstdc++.so /usr/lib/x86_64-linux-gnu/libstdc++.so \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# DEVEL: Add sys env variables to DEVEL image
# Variables in Renviron.site are made available inside of R.
# Add libsbml CFLAGS
ENV LIBSBML_CFLAGS="-I/usr/include"
ENV LIBSBML_LIBS="-lsbml"
RUN echo 'export LIBSBML_CFLAGS="-I/usr/include"' >> /etc/profile \
    && echo 'export LIBSBML_LIBS="-lsbml"' >> /etc/profile

## set pip3 to run as root, not as jupyter user
ENV PIP_USER=false

## Install python packages needed for a few Bioc packages
RUN pip3 -V \
    && pip3 install --upgrade pip \
    && pip3 install cwltool \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN R -e 'install.packages("BiocManager")' \
    ## check version
    && R -e 'BiocManager::install(version="3.15", ask=FALSE)' \
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

RUN R -e 'IRkernel::installspec(user=FALSE)' \
    && chown -R $USER:users /usr/local/lib/R/site-library /home/jupyter

USER $USER
