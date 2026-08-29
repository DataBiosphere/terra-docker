FROM us.gcr.io/broad-dsp-gcr-public/terra-jupyter-r:2.2.7

USER root
SHELL ["/usr/bin/bash", "-o", "pipefail", "-c"]
ENV DEBIAN_FRONTEND=noninteractive

ENV RSTUDIO_PORT=8001
ENV RSTUDIO_HOME=/etc/rstudio
ENV RSTUDIO_USERSETTING=/home/rstudio/.config/rstudio/rstudio-prefs.json

ARG RSTUDIO_VERSION=""
## 1) Install dependencies
RUN apt-get update && apt-get install -yq --no-install-recommends \
    file git \
    libapparmor1 \
    libcurl4-openssl-dev \
    libedit2 \
    libssl-dev \
    lsb-release \
    psmisc \
    procps \
    sudo \
    wget \
    libclang-dev \
    libpq5 \
    && \
    ## 2) Install RStudio Server for Ubuntu 22.04 (Jammy)
    if [[ -z "${RSTUDIO_VERSION}" ]]; then \
      RSTUDIO_URL="https://rstudio.org/download/latest/stable/server/jammy/rstudio-server-latest-amd64.deb"; \
    else \
      RSTUDIO_URL="https://download2.rstudio.org/server/jammy/amd64/rstudio-server-${RSTUDIO_VERSION}-amd64.deb"; \
    fi; \
    wget -qO /tmp/rstudio.deb "${RSTUDIO_URL}" && \
    ## use apt-get install to handle deps
    apt-get install -yq /tmp/rstudio.deb && \
    ## 3) Terra-friendly rstudio user
    if ! id -u rstudio >/dev/null 2>&1; then \
      useradd -m -s /bin/bash -N --non-unique -u 1002 rstudio; \
    fi && \
    usermod -g users rstudio && \
    mkdir -p /home/rstudio/.config/rstudio ${RSTUDIO_HOME} /etc/rstudio && \
    echo 'lock-type=advisory' >> /etc/rstudio/file-locks && \
    ## Grant passwordless sudo
    echo "jupyter ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/90-jupyter-user && \
    echo "rstudio ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/90-rstudio-user && \
    ## CLEANUP: Remove everything no longer needed
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

## 4) Copy config files
COPY rserver.conf ${RSTUDIO_HOME}/rserver.conf
COPY rstudio-prefs.json ${RSTUDIO_USERSETTING}

RUN chown -R rstudio:users /home/rstudio && \
    chown rstudio:users ${RSTUDIO_USERSETTING}

EXPOSE 8001
USER jupyter

