# check=skip=SecretsUsedInArgOrEnv
FROM us.gcr.io/broad-dsp-gcr-public/terra-base:1.0.1

USER root

ENV R_VERSION="4.6.1"
ENV R_HOME="/usr/local/lib/R"
ENV TZ="Etc/UTC"

COPY scripts/install_R_source.sh /rocker_scripts/install_R_source.sh
RUN /rocker_scripts/install_R_source.sh

ENV CRAN="https://cloud.r-project.org"
ENV LANG=en_US.UTF-8

COPY scripts/bin/ /rocker_scripts/bin/
COPY scripts/setup_R.sh /rocker_scripts/setup_R.sh
RUN <<EOF
if grep -q "1000" /etc/passwd; then
    userdel --remove "$(id -un 1000)";
fi
/rocker_scripts/setup_R.sh
EOF

ENV S6_VERSION="v2.1.0.2"
ENV RSTUDIO_VERSION="2026.09.0+174"
ENV DEFAULT_USER="rstudio"
ENV RSTUDIO_PORT=8001
ENV RSTUDIO_HOME=/etc/rstudio
ENV RSTUDIO_USERSETTING=/home/rstudio/.config/rstudio/rstudio-prefs.json

COPY scripts/install_rstudio.sh /rocker_scripts/install_rstudio.sh
COPY scripts/install_s6init.sh /rocker_scripts/install_s6init.sh
COPY scripts/default_user.sh /rocker_scripts/default_user.sh
COPY scripts/init_set_env.sh /rocker_scripts/init_set_env.sh
COPY scripts/init_userconf.sh /rocker_scripts/init_userconf.sh

RUN apt update && apt install -y --no-install-recommends zlib1g-dev perl xz-utils
RUN Rscript -e "install.packages(c('tinytex', 'BiocManager'), repos = 'https://cloud.r-project.org')"

RUN apt-get update \
 && apt-get install -y --no-install-recommends perl xz-utils \
 && rm -rf /var/lib/apt/lists/*

RUN Rscript -e "tinytex::install_tinytex(dir = '/opt/TinyTeX', add_path = FALSE)" \
 && /opt/TinyTeX/bin/x86_64-linux/tlmgr option sys_bin /usr/local/bin \
 && /opt/TinyTeX/bin/x86_64-linux/tlmgr path add \
 && chmod -R a+rwX /opt/TinyTeX

RUN Rscript -e "tinytex::tlmgr_install(c('fancyhdr', 'titlesec', 'enumitem'))"

RUN apt-get update && apt install -y libuv1-dev
RUN Rscript -e "BiocManager::install(c('GenomicRanges', 'Seqinfo', 'limma', 'DESeq2', 'scater', 'scran', \
     'SpatialExperiment', 'SpatialFeatureExperiment'))"

RUN /rocker_scripts/install_rstudio.sh

ENV PASSWORD="bioc"

ENV RSTUDIO_HOME=/home/rstudio
EXPOSE 8001
ENTRYPOINT ["/init"]

