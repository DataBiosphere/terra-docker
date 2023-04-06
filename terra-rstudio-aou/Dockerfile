# Base this image on the Terra AnVIL RStudio-Bioconductor image.
FROM us.gcr.io/broad-dsp-gcr-public/anvil-rstudio-bioconductor:3.16.0

ENV AOU_DOCKER_VERSION=0.1.1
LABEL vendor="The All Of Us Research Program" \
      description="RStudio + Bioconductor docker image for use in the All of Us Researcher Workbench." \
      license="GPL-2.0-or-later" \
      version=$AOU_DOCKER_VERSION \
      url="https://github.com/DataBiosphere/terra-docker"

# BUG: Update broken google-cloud GPG key preventing
#      apt-get update to complete
RUN curl -O https://packages.cloud.google.com/apt/doc/apt-key.gpg \
    && apt-key add apt-key.gpg

# DEBUG: install speedtest-cli to ascertain tc bandwidth throttling is working
RUN apt-get update \
 && apt-get install -yq --no-install-recommends \
    iproute2 \
    speedtest-cli \
 && echo iptables-persistent iptables-persistent/autosave_v4 boolean true | debconf-set-selections \
 && echo iptables-persistent iptables-persistent/autosave_v6 boolean true | debconf-set-selections \
 && apt-get -y install iptables-persistent \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Compile from source during image construction to prevent loading
# packages that have not been updated recently.
ENV BIOCONDUCTOR_USE_CONTAINER_REPOSITORY=FALSE

# Install tidyverse
COPY rstudio/scripts/install_tidyverse.sh /rocker_scripts/install_tidyverse.sh
RUN chmod +x /rocker_scripts/install_tidyverse.sh && /rocker_scripts/install_tidyverse.sh

# Install top-25 most common packages
# This step is very slow and we want to cache it as much as possible to prevent
# users from having a bad experience.
COPY rstudio/scripts/install_bioconductor.R /rocker_scripts/install_bioconductor.R
RUN R -f /rocker_scripts/install_bioconductor.R

# Use binary repos to speed up package installation.
ENV BIOCONDUCTOR_USE_CONTAINER_REPOSITORY=TRUE

# Add our rserver configuration
ADD rstudio/rserver.conf $RSTUDIO_HOME/rserver.conf

# Install Wondershaper from source, for client-side egress limiting.
RUN cd /usr/local/share && \
  git clone https://github.com/magnific0/wondershaper.git --depth 1 && \
  cd wondershaper && \
  make install && \
  cd $HOME

# Expose ports 8787 and disable authentication as this is handled
# internally.  Root access/super powers are disabled.
ENV RSTUDIO_PORT 8787
ENV DISABLE_AUTH=true
EXPOSE $RSTUDIO_PORT

# Hide tc etc from users
RUN chmod 700 -R /usr/sbin/

COPY rstudio/entrypoint.sh /init_aou
RUN chmod +x /init_aou
ENTRYPOINT [ "/init_aou" ]
