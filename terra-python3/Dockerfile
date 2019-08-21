FROM us.gcr.io/broad-dsp-gcr-public/terra-jupyter-base:3d62742

# RUN apt-get update && \
#   apt-get install -yq --no-install-recommends \
#   liblzo2-dev

RUN pip3 install numpy==1.15.2 \
 && pip3 install py4j==0.10.7 \
 && python3 -mpip install matplotlib==3.0.0 \
 && pip3 install pandas==0.23.4 \
 && pip3 install pandas-gbq \
 && pip3 install seaborn==0.9.0 \
 && pip3 install notebook==5.7.8 \
 && pip3 install jupyter==1.0.0 \
 && pip3 install jupyterlab==0.35.4 \
#  && pip3 install python-lzo==1.12 \
 && pip3 install google-api-core==1.5.0 \
 && pip3 install google-cloud-bigquery==1.7.0 \
 && pip3 install google-cloud-bigquery-datatransfer==0.1.1 \
 && pip3 install google-cloud-core==0.28.1 \
 && pip3 install google-cloud-datastore==1.7.0 \
 && pip3 install google-cloud-resource-manager==0.28.1 \
 && pip3 install google-cloud-storage==1.13.0 \
 && pip3 install --ignore-installed firecloud==0.16.18 \
 && pip3 install scikit-learn==0.20.0 \
 && pip3 install statsmodels==0.9.0 \
 && pip3 install ggplot==0.11.5 \
 # fixed current ggplot issue where it imports Timestamp from pandas.lib (deprecated) instead of pandas
 && sed -i 's/pandas.lib/pandas/g' /usr/local/lib/python3.6/site-packages/ggplot/stats/smoothers.py \
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
 && pip3 install markdown==2.6.9 \
 && pip3 install patsy==0.4.1 \
 && pip3 install protobuf==3.7.1 \
 && pip3 install pymc3==3.1 \
 && pip3 install pyparsing==2.2.0 \
 && pip3 install pysam==0.13 \
 && pip3 install python-dateutil==2.6.1 \
 && pip3 install pytz==2017.3 \
 && pip3 install pyvcf==0.6.8 \
 && pip3 install pyyaml==3.12 \
 && pip3 install scipy==1.0.0 \
 && pip3 install six==1.11.0 \
 && pip3 install tensorflow==1.9.0 \
 && pip3 install theano==0.9.0 \
 && pip3 install tqdm==4.19.4 \
 && pip3 install werkzeug==0.12.2 \
 && pip3 install certifi==2016.2.28 \
 && pip3 install intel-openmp==2018.0.0 \
 && pip3 install mkl==2018.0.3 \
 && pip3 install readline==6.2 \
 && pip3 install setuptools==36.4.0 \
 && pip3 install wheel

# Note: this entrypoint is provided for running Jupyter independently of Leonardo.
# When Leonardo deploys this image onto a cluster, the entrypoint is overwritten to enable
# additional setup inside the container before execution.  Jupyter execution occurs when the
# init-actions.sh script uses 'docker exec' to call run-jupyter.sh.
ENTRYPOINT ["/usr/local/bin/jupyter", "notebook"]