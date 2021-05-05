FROM us.gcr.io/broad-dsp-gcr-public/terra-jupyter-base:0.0.20
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
 && pip3 install --upgrade \
   numpy \
   py4j \
   matplotlib \
   pandas \
   pandas-gbq \
   pandas-profiling \
   seaborn \
   python-lzo \
   google-cloud-bigquery \
   google-api-core \
   google-cloud-bigquery-datatransfer \
   google-cloud-datastore \
   google-cloud-resource-manager \
   google-cloud-storage \
   scikit-learn \
   statsmodels \
   ggplot \
   bokeh \
   pyfasta \
   markdown \
   pdoc3 \
   biopython \
   bx-python \
   fastinterval \
   matplotlib-venn \
   bleach \
   cycler \
   h5py \
   html5lib \
   joblib \
   keras \
   patsy \
   protobuf \
   pymc3 \
   pyparsing \
   Cython \
   pysam --no-binary pysam \
   python-dateutil \
   pytz \
   pyvcf \
   pyyaml \
   scipy \
   # Use the cpu version of Tensorflow to eliminate the warnings about absent GPUs on the Cloud Runtime.
   tensorflow_cpu \
   theano \
   tqdm \
   werkzeug \
   certifi \
   intel-openmp \
   mkl \
   readline \
   setuptools \
   wheel \
   plotnine \
   google-resumable-media \
 # Remove this after https://broadworkbench.atlassian.net/browse/CA-1179
 # As of release [google-cloud-bigquery 1.26.0 (2020-07-20)](https://github.com/googleapis/python-bigquery/blob/master/CHANGELOG.md#1260-2020-07-20)
 # the BigQuery Python client uses the BigQuery Storage client by default.
 # This currently causes an error on Terra Cloud Runtimes `the user does not have 'bigquery.readsessions.create' permission
 # for '<Terra billing project id>'`. To work-around this uninstall the dependency so that flag `--use_rest_api` can be used
 # with `%%bigquery` to use the older, slower mechanism for data transfer.
 && pip3 uninstall -y google-cloud-bigquery-storage \
 && sed -i 's/pandas.lib/pandas/g' /usr/local/lib/python3.7/dist-packages/ggplot/stats/smoothers.py \
 # the next few `sed` lines are workaround for a ggplot bug. See https://github.com/yhat/ggpy/issues/662
 && sed -i 's/pandas.tslib.Timestamp/pandas.Timestamp/g' /usr/local/lib/python3.7/dist-packages/ggplot/stats/smoothers.py \
 && sed -i 's/pd.tslib.Timestamp/pd.Timestamp/g' /usr/local/lib/python3.7/dist-packages/ggplot/stats/smoothers.py \
 && sed -i 's/pd.tslib.Timestamp/pd.Timestamp/g' /usr/local/lib/python3.7/dist-packages/ggplot/utils.py

ENV USER jupyter-user
USER $USER
# We want pip to install into the user's dir when the notebook is running.
ENV PIP_USER=true

# Note: this entrypoint is provided for running Jupyter independently of Leonardo.
# When Leonardo deploys this image onto a cluster, the entrypoint is overwritten to enable
# additional setup inside the container before execution.  Jupyter execution occurs when the
# init-actions.sh script uses 'docker exec' to call run-jupyter.sh.
ENTRYPOINT ["/usr/local/bin/jupyter", "notebook"]
