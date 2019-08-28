FROM us.gcr.io/broad-dsp-gcr-public/terra-jupyter-base:0.0.1

USER root
ENV PIP_USER=false
# ENV USER jupyter-user

RUN apt-get update &&  apt-get upgrade -y && \
  apt-get install -yq --no-install-recommends \
  python3.7-dev \
  #remove these 2 once its tested
    #covered in libssl-dev
  python-tk \
  #is current in base, should it be?
  # libbz2-dev \
  tk-dev \
  #TODO: additional pasta to make it work, trim this down
  #in original, but not in base
  # default-jre \
  # default-jdk \
  # aptitude \
  #quarantine
  libssl-dev \
  xz-utils \
  # hdf5-tools \
  libhdf5-dev \
  openssl \
  make \
  liblzo2-dev \
  unzip \ 
  zlib1g-dev \ 
  libz-dev 
  # python3-dev\
  # libopenblas-dev \
  # liblapack-dev \
  # gfortran \
  # gcc \ 
  # python-dev \
  # cython \ 
  # clang \
  # libpng-dev \
  # pkg-config 


#should this be in base?
# ENV PYTHON_VERSION 3.6.8
# ENV UID 1000
# RUN useradd -m -s /bin/bash -N -u $UID $USER
# ENV PYTHONPATH $PYTHONPATH:$JUPYTER_HOME/custom
# ENV PATH PATH:$PYTHONPATH

# lifted from https://github.com/docker-library/python/blob/dd36c08c1f94083476a8579b8bf20c4cd46c6400/3.6/stretch/Dockerfile
# RUN set -ex \
#  \
#  && wget -O python.tar.xz "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz" \
#  && wget -O python.tar.xz.asc "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz.asc" \
#  && export GNUPGHOME="$(mktemp -d)" \
#  && gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "0D96DF4D4110E5C43FBFB17F2D347EA6AA65421D" \
#  && gpg --batch --verify python.tar.xz.asc python.tar.xz \
#  && { command -v gpgconf > /dev/null && gpgconf --kill all || :; } \
#  && rm -rf "$GNUPGHOME" python.tar.xz.asc \
#  && mkdir -p /usr/src/python \
#  && tar -xJC /usr/src/python --strip-components=1 -f python.tar.xz \
#  && rm python.tar.xz \
#  \
#  && cd /usr/src/python \
#  && gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)" \
#  && ./configure \
#     --build="$gnuArch" \
#     --enable-loadable-sqlite-extensions \
#     --enable-shared \
#     --with-system-expat \
#     --with-system-ffi \
#     --without-ensurepip \
#  && make -j "$(nproc)" \
#  && make install \
#  && ldconfig \
#  \
#  && find /usr/local -depth \
#     \( \
#         \( -type d -a \( -name test -o -name tests \) \) \
#         -o \
#         \( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) \
#     \) -exec rm -rf '{}' + \
#  && rm -rf /usr/src/python \
#  \
#  && python3 --version

# make some useful symlinks that are expected to exist
# RUN cd /usr/local/bin \
#    && ln -s idle3 idle \
#    && ln -s pydoc3 pydoc \
#    && ln -s python3 python \
#    && ln -s python3-config python-config

# if this is called "PIP_VERSION", pip explodes with "ValueError: invalid truth value '<VERSION>'"
# ENV PYTHON_PIP_VERSION 19.0.1

#supress this so legitimate errors are more apparent
# ENV PIP_DISABLE_PIP_VERSION_CHECK 1

#TODO is this still needed? Is it covered in the base image?
# RUN set -ex; \
#     \
#     wget -O get-pip.py 'https://bootstrap.pypa.io/get-pip.py'; \
#    \
#     python get-pip.py \
#         --disable-pip-version-check \
#         --no-cache-dir \
#         "pip==$PYTHON_PIP_VERSION" \
#     ; \
#     pip --version; \
#     \
#     find /usr/local -depth \
#         \( \
#             \( -type d -a \( -name test -o -name tests \) \) \
#             -o \
#             \( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) \
#         \) -exec rm -rf '{}' +; \
#     rm -f get-pip.py

RUN pip3 -V \
 && pip3 install --upgrade pip \
 && pip3 install numpy==1.15.2 \
 && pip3 install py4j==0.10.7 \
 && python3 -mpip install matplotlib==3.0.0 \
 && pip3 install pandas==0.23.4 \
 && pip3 install pandas-gbq==0.11.0 \
 && pip3 install seaborn==0.9.0 \
 && pip3 install notebook==5.7.8 \
 && pip3 install jupyter==1.0.0 \
 && pip3 install jupyterlab==0.35.4 \
 && pip3 install python-lzo==1.12 \
 && pip3 install google-cloud-core==0.29.0 \
 && pip3 install google-auth==1.5.1 \
 && pip3 install google-api-core==1.5.0 \
 && pip3 install google-cloud-bigquery==1.9.0 \
 && pip3 install google-cloud-bigquery-datatransfer==0.1.1 \
 && pip3 install google-cloud-datastore==1.7.0 \
 && pip3 install google-cloud-resource-manager==0.28.1 \
 && pip3 install google-cloud-storage==1.13.0 \
 && pip3 install --ignore-installed firecloud==0.16.18 \
 && pip3 install scikit-learn==0.20.0 \
 && pip3 install statsmodels==0.9.0 \
 && pip3 install ggplot==0.11.5 \
 && sed -i 's/pandas.lib/pandas/g' /usr/local/lib/python3.7/dist-packages/ggplot/stats/smoothers.py \
#&& sed -i 's/pandas.lib/pandas/g' /usr/local/lib/python3.6/site-packages/ggplot/stats/smoothers.py \
 && pip3 install bokeh==1.0.0 \
 && pip3 install pyfasta==0.5.2 \
 && pip3 install pdoc==0.3.2 \
 && pip3 install biopython==1.72 \
 && pip3 install bx-python==0.8.2 \
 && pip3 install fastinterval==0.1.1 \
 && pip3 install matplotlib-venn==0.11.5 \
 && pip3 install bleach==1.5.0 \
 && pip3 install cycler==0.10.0 \
 && pip3 install enum34==1.1.6 \
 && pip3 install h5py==2.7.1 \
 && pip3 install html5lib==0.9999999 \
 && pip3 install joblib==0.11 \
 && pip3 install keras==2.2.0 \
 && pip3 install markdown==2.4.1 \
 && pip3 install patsy==0.4.1 \
 && pip3 install protobuf==3.7.1 \
 && pip3 install pymc3==3.1 \
 && pip3 install pyparsing==2.2.0 \
 && pip3 install pysam==0.15.1 \
 && pip3 install python-dateutil==2.6.1 \
 && pip3 install pytz==2017.3 \
 && pip3 install pyvcf==0.6.8 \
 && pip3 install pyyaml==3.12 \
 && pip3 install scipy \
 && pip3 install six==1.11.0 \
 #could be a breaking version, needs testing
 && pip3 install tensorflow==2.0.0a0 \
 && pip3 install theano==0.9.0 \
 && pip3 install tqdm==4.19.4 \
 && pip3 install werkzeug==0.12.2 \
 && pip3 install certifi==2017.4.17 \
 && pip3 install intel-openmp==2018.0.0 \
 && pip3 install mkl==2018.0.3 \
 && pip3 install readline==6.2 \
 && pip3 install setuptools==36.4.0 \
 && pip3 install wheel

ENV USER jupyter-user
USER $USER
ENV PIP_USER=true

# Note: this entrypoint is provided for running Jupyter independently of Leonardo.
# When Leonardo deploys this image onto a cluster, the entrypoint is overwritten to enable
# additional setup inside the container before execution.  Jupyter execution occurs when the
# init-actions.sh script uses 'docker exec' to call run-jupyter.sh.
ENTRYPOINT ["/usr/local/bin/jupyter", "notebook"]