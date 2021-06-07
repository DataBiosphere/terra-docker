FROM us.gcr.io/broad-dsp-gcr-public/terra-jupyter-gatk:1.1.3

USER root

# need to apt-get everything for python since we can only copy pip installed packages
RUN apt-get update && apt-get install -yq --no-install-recommends \
  jq \
  g++ \
  liblz4-dev \
  libmagick++-dev \
  iproute2 \
  # Nirvana/.NET Core dependencies \
  ca-certificates \
  libc6 \
  libgcc1 \
  libgssapi-krb5-2 \
  libicu60 \
  liblttng-ust0 \
  libssl1.0.0 \
  libstdc++6 \
  zlib1g \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*


# Spark setup.
# Copied from terra-jupyter-hail; keep updated.

# Note Spark and Hadoop are mounted from the outside Dataproc VM.
# Make empty conf dirs for the update-alternatives commands.
RUN mkdir -p /etc/spark/conf.dist && mkdir -p /etc/hadoop/conf.empty && mkdir -p /etc/hive/conf.dist \
    && update-alternatives --install /etc/spark/conf spark-conf /etc/spark/conf.dist 100 \
    && update-alternatives --install /etc/hadoop/conf hadoop-conf /etc/hadoop/conf.empty 100 \
    && update-alternatives --install /etc/hive/conf hive-conf /etc/hive/conf.dist 100

ENV HAIL_VERSION=0.2.62
ENV PIP_USER=false

# For dataproc clusters, this path with will be automatically mounted. Else,
# this is effectively ignored. On GCE VMs, this will result in failures to
# import the pyspark package.
ENV PYTHONPATH $PYTHONPATH:/usr/lib/spark/python

RUN pip3 install pypandoc \
    && pip3 install --no-dependencies hail==$HAIL_VERSION \
    && X=$(mktemp -d) \
    && mkdir -p $X \
    && (cd $X && pip3 download hail==$HAIL_VERSION --no-dependencies && \
        unzip hail*.whl &&  \
        grep 'Requires-Dist: ' hail*dist-info/METADATA | sed 's/Requires-Dist: //' | sed 's/ (//' | sed 's/)//' | grep -v 'pyspark' | xargs pip install) \
    && rm -rf $X

ENV PIP_USER=true

# Install Wondershaper from source, for client-side egress limiting.
RUN cd /usr/local/share && \
  git clone https://github.com/magnific0/wondershaper.git --depth 1 && \
  cd wondershaper && \
  make install && \
  cd $HOME

# Plink install
ENV PLINK_VERSION 20210416
RUN mkdir -p /tmp/plink && \
  cd /tmp/plink && \
  curl -L -o plink.zip "http://s3.amazonaws.com/plink1-assets/plink_linux_x86_64_${PLINK_VERSION}.zip" && \
  unzip plink.zip && \
  mv plink /bin/plink && \
  cd $HOME && \
  rm -rf /tmp/plink

# BOLT-LMM install
ENV BOLT_LMM_VERSION v2.3.5
RUN mkdir -p /tmp/bolt-lmm && \
  cd /tmp/bolt-lmm && \
  curl -L -o bolt-lmm.tar.gz "https://storage.googleapis.com/broad-alkesgroup-public/BOLT-LMM/downloads/BOLT-LMM_${BOLT_LMM_VERSION}.tar.gz" && \
  tar -xvzf bolt-lmm.tar.gz && \
  mv "BOLT-LMM_${BOLT_LMM_VERSION}" /opt/bolt-lmm && \
  ln -s "/opt/bolt-lmm/bolt" /bin/bolt && \
  cd $HOME && \
  rm -rf /tmp/bolt-lmm

# REGENIE install
ENV REGENIE_VERSION v2.0.2
RUN mkdir -p /tmp/regenie && \
  cd /tmp/regenie && \
  curl -L -o regenie.zip "https://github.com/rgcgithub/regenie/releases/download/${REGENIE_VERSION}/regenie_${REGENIE_VERSION}.gz_x86_64_Linux.zip" && \
  unzip regenie.zip && \
  mv regenie_${REGENIE_VERSION}.gz_x86_64_Linux /bin/regenie && \
  cd $HOME && \
  rm -rf /tmp/regenie

# Install .NET Core + Nirvana
ENV DOTNET_VERSION=2.1.26
ENV NIRVANA_VERSION 3.14.0
ENV NIRVANA_ZIP_URL="https://github.com/Illumina/Nirvana/releases/download/v${NIRVANA_VERSION}/Nirvana-${NIRVANA_VERSION}-dotnet-2.1.0.zip"

# Based on https://github.com/MichaelStromberg-Illumina/DotNetMisc/blob/master/Dockerfiles/Nirvana/Dockerfile#L13
RUN curl -SL --output dotnet.tar.gz "https://dotnetcli.azureedge.net/dotnet/Runtime/${DOTNET_VERSION}/dotnet-runtime-${DOTNET_VERSION}-linux-x64.tar.gz" \
    && dotnet_sha512='41cc13f14dd7721a079bdd0ab489de40e9d4f32787239a26e7d10fcb0020a8e78d446c3b430b4bf80a557a925b3ca87d7981bfda4bbf9495cc44b1d42d877c40' \
    && echo "${dotnet_sha512} dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -zxf dotnet.tar.gz -C /usr/share/dotnet \
    && rm dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    && mkdir -p /opt/nirvana \
    && curl -SL --output nirvana.zip $NIRVANA_ZIP_URL \
    && unzip -d /opt/nirvana nirvana.zip \
    && rm nirvana.zip

# Install bcftools
RUN mkdir -p /tmp/bcftools && \
    cd /tmp/bcftools && \
    wget https://github.com/samtools/bcftools/releases/download/1.12/bcftools-1.12.tar.bz2 && \
    bzip2 -d bcftools-1.12.tar.bz2 && \
    tar xvf bcftools-1.12.tar && \
    cd bcftools-1.12 && \
    make && \
    make install && \
    cd $HOME && \
    rm -rf /tmp/bcftools

## Environment Configuration

RUN echo "Sys.setenv(RETICULATE_PYTHON = '$(which python3)')" >> ~/.Rprofile

# Install Notebook libraries as the user.

ENV USER jupyter-user
USER $USER

RUN R -e 'BiocManager::install(c( \
  "SAIGEgds", \
  "GENESIS"))'

RUN pip3 install \
  nbstripout \
  "git+git://github.com/all-of-us/workbench-snippets.git#egg=terra_widgets&subdirectory=py" \
  && mkdir -p /home/$USER/.config/git \
  && nbstripout --install --global
