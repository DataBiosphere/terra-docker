# Base image with the required linux kernels and pre-installed nginx
FROM ubuntu/nginx:latest AS nginx_base
RUN apt-get update \
 && apt-get install -yq --no-install-recommends \
    wondershaper \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

FROM bioconductor/bioconductor_docker:RELEASE_3_16

ENV AOU_DOCKER_VERSION=0.1.0
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

ENV DEBIAN_FRONTEND=noninteractive
EXPOSE 80
STOPSIGNAL SIGQUIT

# Install tidyverse
COPY rstudio/scripts/install_tidyverse.sh /rocker_scripts/install_tidyverse.sh
RUN chmod +x /rocker_scripts/install_tidyverse.sh && /rocker_scripts/install_tidyverse.sh

# DEBUG: install speedtest to ascertain wondershaper is working
RUN apt-get update && apt-get install \
	--no-install-recommends --no-install-suggests -y \
	speedtest-cli

# Install Google Cloud SDK
RUN apt-get install -yq --no-install-recommends \
    gnupg \
    lsb-release \
 && echo "deb http://packages.cloud.google.com/apt cloud-sdk main" > /etc/apt/sources.list.d/google-cloud-sdk.list \
 && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - \
 && apt-get update \
 && apt-get install -yq --no-install-recommends \
    google-cloud-sdk \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Install crcmod
RUN pip3 -V \
    && pip3 install --no-cache-dir -U crcmod

# Add rstudio user to users group
RUN usermod -g users rstudio \
    && useradd -m -s /bin/bash -N -u 1001 welder-user

# google-cloud R packages
COPY rstudio/scripts/install_bioconductor.R /rocker_scripts/install_bioconductor.R
RUN R -f /rocker_scripts/install_bioconductor.R

ENV RSTUDIO_PORT 8787
ENV RSTUDIO_HOME /etc/rstudio
ENV RSTUDIO_USERSETTING /home/rstudio/.config/rstudio/rstudio-prefs.json
ENV DISABLE_AUTH=true
ENV ROOT=false

ADD rstudio/rserver.conf $RSTUDIO_HOME/rserver.conf

RUN sed -i 's/"always_save_history": false/"always_save_history": true/g'  $RSTUDIO_USERSETTING \
 && sed -i 's/"save_workspace": "never"/"save_workspace": "always"/g' $RSTUDIO_USERSETTING

EXPOSE $RSTUDIO_PORT

# COPY scripts ${RSTUDIO_HOME}/scripts
RUN find ${RSTUDIO_HOME}/scripts -name '*.sh' -type f | xargs chmod +x \
 && echo "PIP_USER=true" >>  /usr/local/lib/R/etc/Renviron.site

 CMD /bin/bash -c "wondershaper eth0 8096 4048 && nginx -g 'daemon on;' && /init"
