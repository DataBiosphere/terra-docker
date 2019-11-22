FROM us.gcr.io/broad-dsp-gcr-public/terra-jupyter-r:0.0.5-snap

USER root

## Install system dependencies needed
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    byacc \
    automake \
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
    libprotoc-dev \
    librdf0-dev \
    libmagick++-dev \
    libsasl2-dev \
    libpoppler-cpp-dev \
    libprotobuf-dev \
    libpq-dev \
    libperl-dev \
    ## software - perl extentions and modules
    libarchive-extract-perl \
    libfile-copy-recursive-perl \
    libcgi-pm-perl \
    libdbi-perl \
    libdbd-mysql-perl \
    libxml-simple-perl \
    ## Databases and other software
    sqlite \
    openmpi-bin \
    mpi-default-bin \
    openmpi-common \
    openmpi-doc \
    tcl8.5-dev \
    imagemagick \
    tabix \
    ggobi \
    graphviz \
    protobuf-compiler \
    jags \
    ## Additional resources
    xfonts-100dpi \
    xfonts-75dpi \
    biber \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install libsbml
RUN cd /tmp \
    && curl -O https://s3.amazonaws.com/linux-provisioning/libSBML-5.10.2-core-src.tar.gz \
    && tar zxf libSBML-5.10.2-core-src.tar.gz \
    && cd libsbml-5.10.2 \
    && ./configure --enable-layout \
    && make \
    && make install \
    && ldconfig \
    && rm -rf /tmp/libsbml-5.10.2 \
    && rm -rf /tmp/libSBML-5.10.2-core-src.tar.gz

## Pip runs as root
ENV PIP_USER=false

## Install python packages needed for a few Bioc packages
RUN apt-get update \
    && apt-get install -yq --no-install-recommends python3.7-dev \
    && pip3 -V \
    && pip3 install --upgrade pip \
    && pip3 install cwltool==1.0.20190228155703 \
    && pip3 install pandas==0.25.1 \
    && pip3 install pyyaml \
    && pip3 install scikit-learn==0.21.3 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

## Change back to jupyter-user
USER $USER
## pip runs as jupyter-user
ENV PIP_USER=true

## Install Bioconductor Core packages
RUN R -e 'BiocManager::install(c( \
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
