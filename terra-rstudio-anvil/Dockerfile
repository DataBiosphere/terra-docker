# check=skip=SecretsUsedInArgOrEnv
FROM us.gcr.io/broad-dsp-gcr-public/terra-base:1.0.0

USER root

# should be one of patched, devel
ENV R_VERSION="patched"  
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
ENV RSTUDIO_VERSION="2026.01.1+403"
ENV DEFAULT_USER="rstudio"
ENV RSTUDIO_PORT=8001
ENV RSTUDIO_HOME=/etc/rstudio
ENV RSTUDIO_USERSETTING=/home/rstudio/.config/rstudio/rstudio-prefs.json

COPY scripts/install_rstudio.sh /rocker_scripts/install_rstudio.sh
COPY scripts/install_s6init.sh /rocker_scripts/install_s6init.sh
COPY scripts/default_user.sh /rocker_scripts/default_user.sh
COPY scripts/init_set_env.sh /rocker_scripts/init_set_env.sh
COPY scripts/init_userconf.sh /rocker_scripts/init_userconf.sh

RUN mkdir /rstudio
RUN chmod 777 /rstudio

RUN /rocker_scripts/install_rstudio.sh

ENV PASSWORD="bioc"

ENV RSTUDIO_HOME=/home/rstudio
EXPOSE 8001
ENTRYPOINT ["/init"]

