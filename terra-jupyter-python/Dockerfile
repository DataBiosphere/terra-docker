FROM us.gcr.io/broad-dsp-gcr-public/terra-jupyter-base:0.0.19
USER root
# This makes it so pip runs as root, not the user.
ENV PIP_USER=false

RUN apt-get update && apt-get install -yq --no-install-recommends \
  python-tk \
  tk-dev \
  libssl-dev \
  xz-utils \
  libhdf5-dev \
  openssl \
  make \
  liblzo2-dev \
  zlib1g-dev \
  libz-dev \
  libcurl4-openssl-dev \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

ENV HTSLIB_CONFIGURE_OPTIONS="--enable-gcs"

# Dev note: in general, do not pin Python packages to any particular version.
# Depend on the smoke tests to help us identify any package incompatibilties.
#
# If we find that we do need to pin a package version, be sure to:
# 1) Add a comment saying what needs to be true for us to remove the pin.
#    (e.g. link to an issue and put the details there)
# 2) If the smoke tests did not show the problem, add a new test case to improve
#    test coverage for the identified problem.
RUN pip3 -V \
 && pip3 install --upgrade pip \
 && pip3 install numpy \
 && pip3 install py4j \
 && python3 -mpip install matplotlib \
 && pip3 install pandas \
 && pip3 install pandas-gbq \
 && pip3 install pandas-profiling \
 && pip3 install seaborn \
 && pip3 install python-lzo \
 && pip3 install google-cloud-bigquery \
 && pip3 install google-api-core \
 && pip3 install google-cloud-bigquery-datatransfer \
 && pip3 install google-cloud-datastore \
 && pip3 install google-cloud-resource-manager \
 && pip3 install google-cloud-storage \
 && pip3 install scikit-learn \
 && pip3 install statsmodels \
 && pip3 install ggplot \
 && pip3 install bokeh \
 && pip3 install pyfasta \
 && pip3 install markdown \
 && pip3 install pdoc3 \
 && pip3 install biopython \
 && pip3 install bx-python \
 && pip3 install fastinterval \
 && pip3 install matplotlib-venn \
 && pip3 install bleach \
 && pip3 install cycler \
 && pip3 install h5py \
 && pip3 install html5lib \
 && pip3 install joblib \
 && pip3 install keras \
 && pip3 install patsy \
 && pip3 install protobuf \
 && pip3 install pymc3 \
 && pip3 install pyparsing \
 && pip3 install Cython \
 && pip3 install pysam --no-binary pysam \
 && pip3 install python-dateutil \
 && pip3 install pytz \
 && pip3 install pyvcf \
 && pip3 install pyyaml \
 && pip3 install scipy \
 # Use the cpu version of Tensorflow to eliminate the warnings about absent gpus on the Cloud Runtime.
 && pip3 install tensorflow_cpu \
 && pip3 install theano \
 && pip3 install tqdm \
 && pip3 install werkzeug \
 && pip3 install certifi \
 && pip3 install intel-openmp \
 && pip3 install mkl \
 && pip3 install readline \
 && pip3 install setuptools \
 && pip3 install wheel \
 && pip3 install plotnine \
 && pip3 install google-resumable-media \
 # Remove this after https://broadworkbench.atlassian.net/browse/CA-1179
 # As of release [google-cloud-bigquery 1.26.0 (2020-07-20)](https://github.com/googleapis/python-bigquery/blob/master/CHANGELOG.md#1260-2020-07-20)
 # the BigQuery Python client uses the BigQuery Storage client by default.
 # This currently causes an error on Terra Cloud Runtimes `the user does not have 'bigquery.readsessions.create' permission
 # for '<Terra billing project id>'`. To work-around this uninstall the dependency so that flag `--use_rest_api` can be used
 # with `%%bigquery` to use the older, slower mechanism for data transfer.
 && pip3 uninstall -y google-cloud-bigquery-storage

ENV USER jupyter-user
USER $USER
# We want pip to install into the user's dir when the notebook is running.
ENV PIP_USER=true

# Note: this entrypoint is provided for running Jupyter independently of Leonardo.
# When Leonardo deploys this image onto a cluster, the entrypoint is overwritten to enable
# additional setup inside the container before execution.  Jupyter execution occurs when the
# init-actions.sh script uses 'docker exec' to call run-jupyter.sh.
ENTRYPOINT ["/usr/local/bin/jupyter", "notebook"]
