FROM us.gcr.io/broad-dsp-gcr-public/terra-jupyter-python:2.0.0

USER root


ENV PIP_USER=false
ENV PYTHONPATH=$PYTHONPATH:/usr/lib/spark/python
# The user's conda env (the python3 kernel). A bare "python3" resolves to Ubuntu 26.04's
# /usr/bin/python3 (3.14), which has none of the packages below.
ENV PYSPARK_PYTHON=$CONDA_ENV_HOME/bin/python
ENV HAIL_VERSION=0.2.139

# terra-jupyter-base 2.0.1 already registers the python3 kernel (in $JUPYTER_KERNELSPEC_DIR, pointing at
# the conda env) and makes the scripts executable, so the kernelspec.sh call that was here is dropped:
# /opt/conda/share/jupyter/kernels no longer exists and the base's kernelspec.sh writes python3/kernel.json only.
#
# pip is the conda env's: there is no system pip3 on 26.04, and the pip3 on PATH is conda base's, not the
# kernel's env. `python -m zipfile` replaces unzip, which the base image does not install.
RUN PIP="$CONDA_ENV_HOME/bin/python -m pip" \
    # Note Spark and Hadoop are mounted from the outside Dataproc VM.
    # Make empty conf dirs for the update-alternatives commands.
    && mkdir -p /etc/spark/conf.dist && mkdir -p /etc/hadoop/conf.empty && mkdir -p /etc/hive/conf.dist \
    && update-alternatives --install /etc/spark/conf spark-conf /etc/spark/conf.dist 100 \
    && update-alternatives --install /etc/hadoop/conf hadoop-conf /etc/hadoop/conf.empty 100 \
    && update-alternatives --install /etc/hive/conf hive-conf /etc/hive/conf.dist 100 \
    && apt-get update \
    # Note that starting on 2.1.x, dataproc VM also provides java 11, which is incompatible with 8. No need to install it in the container
    # && apt install -yq --no-install-recommends openjdk-8-jdk \
    #     g++ \
    #     liblz4-dev \
    # && update-alternatives --set java /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java \
    && $PIP install --no-cache-dir --root-user-action=ignore pypandoc gnomad==0.6.4 \
    && $PIP install --no-cache-dir --root-user-action=ignore --no-dependencies hail==$HAIL_VERSION \
    && X=$(mktemp -d) \
    && requirements_file=$(mktemp) \
    && mkdir -p $X \
    && (cd $X && $PIP download --no-cache-dir hail==$HAIL_VERSION --no-dependencies && \
        $CONDA_ENV_HOME/bin/python -m zipfile -e hail*.whl . && \
        grep 'Requires-Dist: ' hail*dist-info/METADATA | sed 's/Requires-Dist: //' | sed 's/ (//' | sed 's/)//' | grep -v 'pyspark' >$requirements_file && \
        $PIP install --no-cache-dir --root-user-action=ignore -r $requirements_file) \
    && rm -rf $X $requirements_file \
    # Files pip added are root-owned; hand them to the jupyter user (only those, so the rest of the env
    # is not copied into this layer) so `pip install` in a notebook can upgrade them.
    && find $CONDA_ENV_HOME ! -user $USER -exec chown -h $USER:users {} + \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENV PIP_USER=true
USER $USER
