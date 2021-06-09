FROM us.gcr.io/broad-dsp-gcr-public/terra-jupyter-base:0.0.20
USER root

COPY scripts $JUPYTER_HOME/scripts

# Add env vars to identify binary package installation
ENV TERRA_R_PLATFORM="terra-jupyter-r"
ENV TERRA_R_PLATFORM_BINARY_VERSION=3.13.0

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
	mpi-default-bin \
	openmpi-common \
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
<<<<<<< HEAD
        libsbml5-dev \
        libzmq3-dev \
=======
	libsbml5-dev \
	biber \
>>>>>>> 5738cad (use blessed image)
    && ln -s /usr/lib/gcc/x86_64-linux-gnu/7/libgfortran.so /usr/lib/x86_64-linux-gnu/libgfortran.so \
    && ln -s /usr/lib/gcc/x86_64-linux-gnu/7/libstdc++.so /usr/lib/x86_64-linux-gnu/libstdc++.so \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

<<<<<<< HEAD
=======
# DEVEL: Add sys env variables to DEVEL image
# Variables in Renviron.site are made available inside of R.
# Add libsbml CFLAGS
>>>>>>> 5738cad (use blessed image)
ENV LIBSBML_CFLAGS="-I/usr/include"
ENV LIBSBML_LIBS="-lsbml"
RUN echo 'export LIBSBML_CFLAGS="-I/usr/include"' >> /etc/profile \
    && echo 'export LIBSBML_LIBS="-lsbml"' >> /etc/profile

## set pip3 to run as root, not as jupyter user
ENV PIP_USER=false

## Install python packages needed for a few Bioc packages
RUN apt-get update \
    && apt-get install -yq --no-install-recommends \
    && pip3 -V \
    && pip3 install --upgrade pip \
    && pip3 install cwltool==1.0.20190228155703 \
    && pip3 install pandas==0.25.3 \
    && pip3 install pyyaml==5.3.1 \
    && pip3 install scikit-learn==0.21.3 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN R -e 'install.packages("BiocManager")' \
    ## check version
    && R -e 'BiocManager::install(version="3.13", ask=FALSE)' \
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
		&& R -e 'BiocManager::install("DataBiosphere/Ronaldo")' \
    && chown -R $USER:users /home/jupyter/.local

## pip runs as jupyter-user
ENV PIP_USER=true

RUN R -e 'IRkernel::installspec(user=FALSE)' \
    && chown -R $USER:users /usr/local/lib/R/site-library

USER $USER
