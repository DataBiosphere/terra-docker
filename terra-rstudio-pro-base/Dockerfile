FROM rstudio/rstudio-server-pro:1.2.5042-1

# install OS dependencies and google-cloud-sdk
RUN apt-get update && apt-get install -yq --no-install-recommends \
    lsb-release \
    software-properties-common \
 && export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)" \
 && echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" > /etc/apt/sources.list.d/google-cloud-sdk.list \
 && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - \
 && apt-get update \
 && apt-get install -yq --no-install-recommends \
    google-cloud-sdk \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# install BiocManager and google-cloud R packages
# TODO: should we include other bioconductor setup?
RUN R -e "install.packages(c( \
  'remotes', \
  'BiocManager', \
  'devtools'), \
  repos = 'http://cran.us.r-project.org')" \ 
 && R -e "BiocManager::install(c( \
    'DataBiosphere/Ronaldo', \
    'bigrquery',  \
    'googleCloudStorageR'))"

ENV RSTUDIO_PORT 8001
ENV RSTUDIO_HOME /etc/rstudio

ADD conf/rserver.conf $RSTUDIO_HOME/rserver.conf

EXPOSE $RSTUDIO_PORT
