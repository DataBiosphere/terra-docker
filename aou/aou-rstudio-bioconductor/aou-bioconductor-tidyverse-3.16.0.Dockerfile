# Base image with the required linux kernels and pre-installed nginx
FROM ubuntu/nginx:latest AS nginx_base
RUN apt-get update \
 && apt-get install -yq --no-install-recommends \
    wondershaper \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*


# Base this image on the Terra AnVIL RStudio-Bioconductor image.
FROM us.gcr.io/broad-dsp-gcr-public/anvil-rstudio-bioconductor:3.16.0

ENV AOU_DOCKER_VERSION=3.16.0
LABEL vendor="The All Of Us Research Program" \
      description="RStudio + Bioconductor docker image for use in the All of Us Researcher Workbench." \
      license="GPL-2.0-or-later" \
      version=$AOU_DOCKER_VERSION \
      url="https://github.com/DataBiosphere/terra-docker"

# Copy over the required files from the first stage
COPY --from=nginx_base /lib/ /lib/
COPY --from=nginx_base /sbin/ /sbin/
COPY --from=nginx_base /docker-entrypoint.d/ /docker-entrypoint.d/
COPY --from=nginx_base /var/log/nginx/ /var/log/nginx/
COPY --from=nginx_base /etc/nginx/ /etc/nginx/
COPY --from=nginx_base /usr/share/ /usr/share/
COPY --from=nginx_base /var/lib/nginx/ /var/lib/nginx/

# Expose port 80 for nginx
EXPOSE 80
STOPSIGNAL SIGQUIT

# BUG: Delete broken google-cloud-sdk list and key preventing
#      apt-get update to complete
RUN rm -f /etc/apt/sources.list.d/google-cloud-sdk.list && rm -f /usr/share/keyrings/cloud.google.gpg && rm -f /usr/share/keyrings/cloud.google.gpg~

# DEBUG: install speedtest-cli to ascertain wondershaper is working
RUN apt-get update && apt-get install \
	--no-install-recommends --no-install-suggests -y \
	speedtest-cli

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

# Expose ports 8787 and disable authentication as this is handled
# internally.  Root access/super powers are disabled.
ENV RSTUDIO_PORT 8787
ENV DISABLE_AUTH=true
ENV ROOT=false
EXPOSE $RSTUDIO_PORT

# Install su-exec
RUN cd /tmp && git clone https://github.com/ncopa/su-exec.git && cd su-exec && make && cp su-exec /usr/local/bin && rm -rf /tmp/su-exec

# Run wondershaper to limit network bandwidth to 8mbps down and 4mbps up as
# a different user than RStudio user which is set in the /init script.
# CMD /bin/bash -c 'su-exec "wondershaper eth0 8096 4048" root rstudio && su-exec "nginx -g \'daemon on;\'" && /init'
COPY rstudio/entrypoint.sh /init_aou
RUN chmod +x /init_aou
ENTRYPOINT [ "/init_aou" ]
