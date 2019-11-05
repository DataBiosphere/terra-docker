FROM us.gcr.io/broad-dsp-gcr-public/terra-jupyter-base:0.0.5
USER root

COPY scripts $JUPYTER_HOME/scripts

RUN find $JUPYTER_HOME/scripts -name '*.sh' -type f | xargs chmod +x

# https://cran.r-project.org/bin/linux/ubuntu/README.html
RUN apt-get update \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9 \
    && add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran35/' \
    && apt-get install -yq --no-install-recommends apt-transport-https \
    && apt update \
#     && apt-get -y build-dep libcurl4-gnutls-dev \
    && apt install -yq --no-install-recommends \
	apt-utils \
	curl \
	libssh2-1-dev \
	libssl-dev \
	libcurl4-gnutls-dev \
	libgit2-dev \
	libxml2-dev \
	# libcurl4-gnutls-dev \
	r-base-dev \
	r-base-core \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

USER $USER

## Reasons for change, 1. Message during installation, 2. User cannot
## update packages installed in the Dockerfile.

RUN  mkdir -p /home/jupyter-user/.rpackages \
 && echo "R_LIBS=/home/jupyter-user/.rpackages" > /home/jupyter-user/.Renviron \
 && R -e 'install.packages(c( \
    "remotes", \
    "BiocManager", \
    "devtools"))' \
 && R -e 'BiocManager::install(version="3.9", ask=FALSE)' \
 && R -e 'BiocManager::install(c( \
    "boot", \
    "class", \
    "cluster", \
    "codetools", \
    "foreign", \
    "kernsmooth", \
    "lattice", \
    "mass", \
    "matrix", \
    "mgcv", \
    "nlme", \
    "nnet", \
    "rpart", \
    "spatial", \
    "survival", \
    # Jupyter notebook essentials
    "IRdisplay",  \
    "DataBiosphere/Ronaldo", \
    "IRkernel/IRkernel", \
    # GCP essentials
    "bigrquery",  \
    "googleCloudStorageR", \
    # User oriented packages
    "tidyverse", \
    "pbdZMQ", \
    "uuid"))' \
 && R -e 'IRkernel::installspec(user=FALSE)' \
 && chown -R $USER:users /home/jupyter-user/.local

