FROM us.gcr.io/broad-dsp-gcr-public/terra-jupyter-r:2.1.6

USER root

## Install Bioconductor Core packages
RUN curl -O https://raw.githubusercontent.com/Bioconductor/anvil-docker/master/anvil-rstudio-bioconductor/install.R \
	&& R -f install.R \
	&& rm -rf install.R

RUN chown -R $USER:users /opt/conda

USER $USER
