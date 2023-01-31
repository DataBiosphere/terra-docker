# Starting with a different base compared to the original rocker/r image
# The R and Rstudio sections are copied from the original rocker images
# The Bioconductor section is copied from the Bioconductor image
# The Anvil section is modified from the Anvil image
# Ubuntu 22.04 jammy + nginx 1.18
FROM ubuntu/nginx:1.18-22.04_beta

ENV AOU_DOCKER_VERSION=0.1.0
LABEL vendor="The All Of Us Research Program" \
      description="RStudio + Bioconductor docker image for use in the All of Us Researcher Workbench." \
      license="GPL-2.0-or-later" \
      version=$AOU_DOCKER_VERSION \
      url="https://github.com/DataBiosphere/terra-docker"

ENV R_VERSION=4.2.2
ENV R_HOME=/usr/local/lib/R
ENV TZ="America/New_York"

# Add speedtest-cli if debugging network performance
RUN apt-get update && apt-get install \
	--no-install-recommends --no-install-suggests -y \
	wondershaper speedtest-cli

COPY scripts/install_R_source.sh /rocker_scripts/install_R_source.sh

RUN /rocker_scripts/install_R_source.sh

ENV CRAN=https://packagemanager.posit.co/cran/__linux__/jammy/latest
ENV LANG=en_US.UTF-8

COPY scripts /rocker_scripts

RUN /rocker_scripts/setup_R.sh

# rstudio_4.2.2.Dockerfile
ENV S6_VERSION=v2.1.0.2
ENV RSTUDIO_VERSION=2022.12.0+353
ENV DEFAULT_USER=rstudio
ENV PANDOC_VERSION=default
ENV QUARTO_VERSION=default

RUN /rocker_scripts/install_rstudio.sh
RUN /rocker_scripts/install_pandoc.sh
RUN /rocker_scripts/install_quarto.sh

EXPOSE 8787

# Bioconductor
## Set Dockerfile version number
ARG BIOCONDUCTOR_VERSION=3.17

##### IMPORTANT ########
## The PATCH version number should be incremented each time
## there is a change in the Dockerfile.
ARG BIOCONDUCTOR_PATCH=12
ARG BIOCONDUCTOR_DOCKER_VERSION=${BIOCONDUCTOR_VERSION}.${BIOCONDUCTOR_PATCH}

## Do not use binary repositories during container creation
## Avoid using binaries produced for older version of same container
ENV BIOCONDUCTOR_USE_CONTAINER_REPOSITORY=FALSE

##  Add Bioconductor system dependencies
ADD scripts/install_bioc_sysdeps.sh /tmp/
RUN bash /tmp/install_bioc_sysdeps.sh

## Add host-site-library
RUN echo "R_LIBS=/usr/local/lib/R/host-site-library:\${R_LIBS}" > /usr/local/lib/R/etc/Renviron.site

## Install specific version of BiocManager
ADD scripts/install.R /tmp/
RUN R -f /tmp/install.R

# DEVEL: Add sys env variables to DEVEL image
# Variables in Renviron.site are made available inside of R.
# Add libsbml CFLAGS
RUN curl -O http://bioconductor.org/checkResults/devel/bioc-LATEST/Renviron.bioc \
    && sed -i '/^IS_BIOC_BUILD_MACHINE/d' Renviron.bioc \
    && cat Renviron.bioc | grep -o '^[^#]*' | sed 's/export //g' >>/etc/environment \
    && cat Renviron.bioc >> /usr/local/lib/R/etc/Renviron.site \
    && echo BIOCONDUCTOR_VERSION=${BIOCONDUCTOR_VERSION} >> /usr/local/lib/R/etc/Renviron.site \
    && echo BIOCONDUCTOR_DOCKER_VERSION=${BIOCONDUCTOR_DOCKER_VERSION} >> /usr/local/lib/R/etc/Renviron.site \
    && echo 'LIBSBML_CFLAGS="-I/usr/include"' >> /usr/local/lib/R/etc/Renviron.site \
    && echo 'LIBSBML_LIBS="-lsbml"' >> /usr/local/lib/R/etc/Renviron.site \
    && rm -rf Renviron.bioc

ENV LIBSBML_CFLAGS="-I/usr/include"
ENV LIBSBML_LIBS="-lsbml"
ENV BIOCONDUCTOR_DOCKER_VERSION=$BIOCONDUCTOR_DOCKER_VERSION
ENV BIOCONDUCTOR_VERSION=$BIOCONDUCTOR_VERSION

## Use binary repos after
ENV BIOCONDUCTOR_USE_CONTAINER_REPOSITORY=TRUE

# ANVIL
RUN apt-get update && apt-get install -yq --no-install-recommends \
    gnupg \
    lsb-release \
 && echo "deb http://packages.cloud.google.com/apt cloud-sdk main" > /etc/apt/sources.list.d/google-cloud-sdk.list \
 && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - \
 && apt-get update \
 && apt-get install -yq --no-install-recommends \
    google-cloud-sdk \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN pip3 -V \
    && pip3 install --no-cache-dir -U crcmod

# add rstudio user to users group
RUN usermod -g users rstudio \
    && useradd -m -s /bin/bash -N -u 1001 welder-user

# google-cloud R packages
## Install specific version of BiocManager
RUN R -f /rocker_scripts/install_bioconductor.R

ENV RSTUDIO_HOME /etc/rstudio
ENV RSTUDIO_USERSETTING /home/rstudio/.config/rstudio/rstudio-prefs.json

ADD rserver.conf $RSTUDIO_HOME/rserver.conf

RUN sed -i 's/"always_save_history": false/"always_save_history": true/g' $RSTUDIO_USERSETTING \
 && sed -i 's/"save_workspace": "never"/"save_workspace": "always"/g' $RSTUDIO_USERSETTING

COPY user_scripts ${RSTUDIO_HOME}/scripts
RUN find ${RSTUDIO_HOME}/scripts -name '*.sh' -type f | xargs chmod +x \
 && echo "PIP_USER=true" >>  /usr/local/lib/R/etc/Renviron.site

ENV DISABLE_AUTH=true
ENV ROOT=false

# Restrict download speed to 8Mbit/s = 1MB/s and upload speeds to 4Mbit/s = 512KB/s
# Wondershaper will be executed as a different user compared to the rstudio user
# in /init.  Should not be possible to reset Wondershaper to unlimited speeds or delete
# the Wondershaper executable.
# TODO: Add VPC ip addresses to whitelist
CMD /bin/bash -c "wondershaper eth0 8096 4048 && nginx -g 'daemon on;' && /init"
