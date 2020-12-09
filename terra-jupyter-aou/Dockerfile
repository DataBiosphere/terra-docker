FROM us.gcr.io/broad-dsp-gcr-public/terra-jupyter-python:0.0.22 AS python

FROM us.gcr.io/broad-dsp-gcr-public/terra-jupyter-r:1.0.11

# copy everything pip installed from the python image
COPY --from=python /usr/local/lib/python3.7/dist-packages /usr/local/lib/python3.7/dist-packages

USER root

# need to apt-get everything for python since we can only copy pip installed packages
RUN apt-get update && apt-get install -yq --no-install-recommends \
  jq \
  python3.7-dev \
  python-tk \
  openjdk-8-jdk \
  tk-dev \
  libssl-dev \
  xz-utils \
  libhdf5-dev \
  openssl \
  make \
  g++ \
  liblz4-dev \
  liblzo2-dev \
  zlib1g-dev \
  libz-dev \
  libmagick++-dev \
  iproute2 \
  # specify Java 8
  && update-alternatives --set java /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java \
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

ENV HAIL_VERSION=0.2.57
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

# Install the variantstore branch of the GATK jar. This will eventually be
# merged into the main release, at which point we can simply download the usual
# GATK release jar and delete this entire section.
ENV VARSTORE_GATK_RELEASE=4.1.8.1-127-g0360115-SNAPSHOT-local
ENV GATK_LOCAL_JAR=/usr/local/share/gatk.jar

RUN curl -L -o "${GATK_LOCAL_JAR}" \
  "https://storage.googleapis.com/storage/v1/b/broad-dsp-spec-ops-public/o/gatk-package-${VARSTORE_GATK_RELEASE}.jar?alt=media"

ENV VARSTORE_TOOLS_VERSION=bdd7f95
RUN git clone https://github.com/broadinstitute/variantstore.git /tmp/varstore && \
  cd /tmp/varstore && \
  git checkout "${VARSTORE_TOOLS_VERSION}" && \
  mv "extract/raw_array_cohort_extract.py" /usr/local/share/ && \
  cd $HOME && \
  rm -rf /tmp/varstore

ENV PLINK_VERSION=20201019
RUN mkdir -p /tmp/plink && \
  cd /tmp/plink && \
  curl -L -o plink.zip "http://s3.amazonaws.com/plink1-assets/plink_linux_x86_64_${PLINK_VERSION}.zip" && \
  unzip plink.zip && \
  mv plink /bin/plink && \
  cd $HOME && \
  rm -rf /tmp/plink

RUN echo "Sys.setenv(RETICULATE_PYTHON = '$(which python3)')" >> ~/.Rprofile

# Install Notebook libraries as the user.

ENV USER jupyter-user
USER $USER

RUN pip3 install --upgrade \
  # Fix plotnine and its dependency mizani to a version that's compatible with 0.25.* of pandas.
  # The next versions require pandas 1.0 which we're not ready to upgrade to just yet.
  plotnine==0.6.0 \
  mizani==0.6.0 \
  # Parent image pins tensorflow to an old alpha version. Override here for now.
  tensorflow==2.3.0 \
  numpy==1.18.5 \
  statsmodels==0.10.0rc2 \
  "git+git://github.com/all-of-us/workbench-snippets.git#egg=terra_widgets&subdirectory=py"

RUN R -e 'devtools::install_github("all-of-us/bigrquery")'
