FROM us.gcr.io/broad-dsp-gcr-public/terra-jupyter-gatk:2.3.1

USER root

# need to apt-get everything for python since we can only copy pip installed packages
RUN apt-get update && apt-get install -yq --no-install-recommends \
  jq \
  g++ \
  less \
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


ENV PIP_USER=false

RUN pip3 install --upgrade \
  "pandas_profiling==3.6.6" \
  "markupsafe==2.1.2"

RUN pip3 install \
      nbstripout \
      papermill \
      dsub \
      "git+https://github.com/all-of-us/workbench-snippets.git#egg=terra_widgets&subdirectory=py"


# 2.0.0 has breaking changes and we're not ready for them yet.
RUN pip3 install "igv-jupyter>=1.0.0,<2.0.0"
RUN jupyter nbextension enable --py igv --sys-prefix

# Spark/Hail setup.
# Copied from terra-jupyter-hail; keep updated.
ENV PYTHONPATH $PYTHONPATH:/usr/lib/spark/python

ENV PYSPARK_PYTHON=python3

ENV HAIL_VERSION=0.2.119

RUN find $JUPYTER_HOME/scripts -name '*.sh' -type f | xargs chmod +x \
    && $JUPYTER_HOME/scripts/kernel/kernelspec.sh $JUPYTER_HOME/scripts/kernel /opt/conda/share/jupyter/kernels \
    # Note Spark and Hadoop are mounted from the outside Dataproc VM.
    # Make empty conf dirs for the update-alternatives commands.
    && mkdir -p /etc/spark/conf.dist && mkdir -p /etc/hadoop/conf.empty && mkdir -p /etc/hive/conf.dist \
    && update-alternatives --install /etc/spark/conf spark-conf /etc/spark/conf.dist 100 \
    && update-alternatives --install /etc/hadoop/conf hadoop-conf /etc/hadoop/conf.empty 100 \
    && update-alternatives --install /etc/hive/conf hive-conf /etc/hive/conf.dist 100 \
    && apt-get update \
    && apt install -yq --no-install-recommends openjdk-8-jdk \
        g++ \
        liblz4-dev \
    # specify Java 8
    && update-alternatives --set java /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java \
    && pip3 install pypandoc gnomad \
    && pip3 install --no-dependencies hail==$HAIL_VERSION \
    && X=$(mktemp -d) \
    && requirements_file=$(mktemp) \
    && mkdir -p $X \
    && (cd $X && pip3 download hail==$HAIL_VERSION --no-dependencies && \
        unzip hail*.whl && \
        grep 'Requires-Dist: ' hail*dist-info/METADATA | sed 's/Requires-Dist: //' | sed 's/ (//' | sed 's/)//' | grep -v 'pyspark' >$requirements_file && \
        pip install -r $requirements_file) \
    && rm -rf $X \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

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
  curl -fsSL -o plink.zip "http://s3.amazonaws.com/plink1-assets/plink_linux_x86_64_${PLINK_VERSION}.zip" && \
  unzip plink.zip && \
  mv plink /bin/plink && \
  cd $HOME && \
  rm -rf /tmp/plink

RUN mkdir -p /tmp/plink2 && \
  cd /tmp/plink2 && \
  curl -fsSL -o plink2.zip "https://s3.amazonaws.com/plink2-assets/alpha2/plink2_linux_x86_64.zip" && \
  unzip plink2.zip && \
  mv plink2 /bin/plink2 && \
  cd $HOME && \
  rm -rf /tmp/plink2

RUN mkdir -p /tmp/prsice && \
  cd /tmp/prsice && \
  curl -fsSL -o prsice.zip https://github.com/choishingwan/PRSice/releases/download/2.3.5/PRSice_linux.zip && \
  unzip prsice.zip && \
  rm prsice.zip && \
  cd $HOME && \
  mv /tmp/prsice /opt/prsice && \
  ln -s "/opt/prsice/PRsice_linux" /bin/prsice

# BOLT-LMM install
ENV BOLT_LMM_VERSION v2.4.1
RUN mkdir -p /tmp/bolt-lmm && \
  cd /tmp/bolt-lmm && \
  curl -fsSL -o bolt-lmm.tar.gz "https://storage.googleapis.com/broad-alkesgroup-public/BOLT-LMM/downloads/BOLT-LMM_${BOLT_LMM_VERSION}.tar.gz" && \
  tar -xvzf bolt-lmm.tar.gz && \
  mv "BOLT-LMM_${BOLT_LMM_VERSION}" /opt/bolt-lmm && \
  ln -s "/opt/bolt-lmm/bolt" /bin/bolt && \
  cd $HOME && \
  rm -rf /tmp/bolt-lmm

# REGENIE install
ENV REGENIE_VERSION v2.0.2
RUN mkdir -p /tmp/regenie && \
  cd /tmp/regenie && \
  curl -fsSL -o regenie.zip "https://github.com/rgcgithub/regenie/releases/download/${REGENIE_VERSION}/regenie_${REGENIE_VERSION}.gz_x86_64_Linux.zip" && \
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

ENV GCTA_VERSION=v1.94.0Beta
RUN mkdir -p /tmp/gcta && \
    cd /tmp/gcta && \
    curl -fsSL -o gcta.zip "https://yanglab.westlake.edu.cn/software/gcta/bin/gcta_${GCTA_VERSION}_linux_kernel_4_x86_64.zip" && \
    unzip gcta.zip && \
    mv "gcta_${GCTA_VERSION}_linux_kernel_4_x86_64/gcta_${GCTA_VERSION}_linux_kernel_4_x86_64_static" /bin/gcta && \
    cd $HOME && \
    rm -rf /tmp/gcta

# Install bcftools
RUN mkdir -p /tmp/bcftools && \
    cd /tmp/bcftools && \
    curl -fsSL -o bcftools.tar.bz2 https://github.com/samtools/bcftools/releases/download/1.12/bcftools-1.12.tar.bz2 && \
    bzip2 -d bcftools.tar.bz2 && \
    tar xvf bcftools.tar && \
    cd bcftools-1.12 && \
    make && \
    make install && \
    cd $HOME && \
    rm -rf /tmp/bcftools

# Install vcftools
RUN mkdir -p /tmp/vcftools && \
    cd /tmp/vcftools && \
    curl -fsSL -o vcftools.tar.gz https://github.com/vcftools/vcftools/releases/download/v0.1.16/vcftools-0.1.16.tar.gz && \
    tar xvzf vcftools.tar.gz && \
    cd vcftools-0.1.16 && \
    ./configure && \
    make && \
    make install && \
    cd $HOME && \
    rm -rf /tmp/vcftools

RUN R -e 'BiocManager::install(c("GENESIS"))'

RUN R -e 'BiocManager::install(c("SAIGEgds","SNPRelate"))'

# Install hdf5 library and h5py
RUN apt-get update && \
  apt install -yq --no-install-recommends \
        libhdf5-serial-dev \
        cmake \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/*
RUN pip install --upgrade pip && pip install --verbose h5py

# RW-8725 INSTALL QIMEE2
RUN curl -fsSL -o qiime2-2022.8.yml https://data.qiime2.org/distro/core/qiime2-2022.8-py38-linux-conda.yml && \
    conda env create -n qiime2-2022.8 --file qiime2-2022.8.yml && \
    rm qiime2-2022.8.yml

# Install jellyfish
RUN mkdir -p /tmp/jellyfish && \
    cd /tmp/jellyfish && \
    curl -fsSL -o jellyfish.tar.gz https://github.com/gmarcais/Jellyfish/releases/download/v2.3.0/jellyfish-2.3.0.tar.gz && \
    tar xvf jellyfish.tar.gz && \
    cd jellyfish-2.3.0 && \
    ./configure && \
    make && \
    make install && \
    cd $HOME && \
    rm -rf /tmp/jellyfish

# Install pangenie
RUN mkdir -p /tmp/pangenie && \
  cd /tmp/pangenie && \
  git clone https://github.com/eblerjana/pangenie.git && \
  cd pangenie && \
  mkdir build; cd build; cmake .. ; make && cd src && \
  mv *.so /lib && \
  mv * /bin/ && \
  cd $HOME && \
  rm -rf /tmp/pangenie

# Install minimap2
RUN curl -fsSL https://github.com/lh3/minimap2/releases/download/v2.24/minimap2-2.24_x64-linux.tar.bz2 | tar -jxvf - && cd minimap2-2.24_x64-linux/ && cp minimap2 /bin/minimap2 && cd $HOME

# Run whatshap (>1h install)
# RUN conda install -c bioconda whatshap
# Alternatively, not using conda (1 min install)
RUN pip install --verbose git+https://github.com/whatshap/whatshap

# TRF
RUN mkdir -p /tmp/trf && cd /tmp/trf && \
  git clone https://github.com/Benson-Genomics-Lab/TRF.git && cd TRF && \
  mkdir build && cd build && ../configure && make && make install && \
  cd $HOME && \
  rm -rf /tmp/trf

# HMMER
RUN mkdir -p /tmp/hmmer && cd /tmp/hmmer && \
  curl -fsSL -o hmmer-3.3.tar.gz http://eddylab.org/software/hmmer/hmmer-3.3.tar.gz && \
  tar -xzf hmmer-3.3.tar.gz && cd hmmer-3.3 && ./configure && \
  make && make install && cd .. && rm -r hmmer-3.3 hmmer-3.3.tar.gz && cd $HOME && \
  rm -rf /tmp/hmmer

# rmblast (200M)
RUN mkdir -p /tmp/rmblast && cd /tmp/rmblast && \
  curl -fsSL -o rmblast-2.11.0+-x64-linux.tar.gz http://www.repeatmasker.org/rmblast-2.11.0+-x64-linux.tar.gz && \
  tar -zxvf rmblast-2.11.0+-x64-linux.tar.gz && \
  cp rmblast-2.11.0/bin/* /usr/local/bin && \
  cd $HOME && \
  rm -rf /tmp/rmblast

RUN PERL_MM_USE_DEFAULT=1 cpan Text::Soundex

# Install RepeatMasker (900M)
RUN curl -fsSL http://www.repeatmasker.org/RepeatMasker/RepeatMasker-4.1.4.tar.gz \
  | (cd /usr/local; tar -xz)

# Remove workspace_cromwell script as it may allow user bypass AoU to create Cromwell via Leo directly
RUN rm -f /usr/local/bin/workspace_cromwell.py

# Downgrade Jinja2 as the newer version breaks the notebook
# See https://jinja.palletsprojects.com/en/3.1.x/changes/#version-3-1-0
RUN pip install --force-reinstall -v "Jinja2==3.0.3"

ENV PATH="$PATH:/usr/local/RepeatMasker"

ENV PIP_USER=true
USER $USER
