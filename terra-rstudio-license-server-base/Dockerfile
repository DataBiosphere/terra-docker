FROM marketplace.gcr.io/google/ubuntu1804:latest
USER root

ENV RSTUDIO_LICENSE_SERVER_VERSION 1.0.9

RUN set -x \
    && apt-get update \
    && apt-get install -y \
        r-base \
        gdebi \
        git \
        curl \
        libcurl4-openssl-dev \
        libssl-dev \
        ed \
        cron \
        libmysqlclient-dev \
        libxml2-dev \
        ruby \
        ruby-dev \
        netcat \
        libxcrypt1 \
        locales \
        sudo

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen en_US.UTF-8 && \
    /usr/sbin/update-locale LANG=en_US.UTF-8
ENV LC_ALL en_US.UTF-8

RUN curl -fSL https://s3.amazonaws.com/rstudio-license-server/rsp-license-server-${RSTUDIO_LICENSE_SERVER_VERSION}-x86_64.deb -o /tmp/rsp-license-server.deb # \
    && dpkg -i /tmp/rsp-license-server.deb \
    && rsp-license-server activate WCSJ-7C3K-GSQQ-VSDQ-BYH7-NPFJ-DATA
#
#RUN /usr/bin/R -e 'install.packages(c("httr","devtools"), repo = "http://cran.rstudio.com")'
#RUN /usr/bin/R -e 'devtools::install_version("mosaic",version="0.14.4", repos = "http://cran.us.r-project.org")'
#RUN /usr/bin/R -e 'devtools::install_version("testthat",repos = "http://cran.us.r-project.org")'
#RUN /usr/bin/R -e 'devtools::install_github("MangoTheCat/visualTest")'
#ARG CACHE_DATE=not_a_date
#RUN /usr/bin/R -e 'devtools::install_github("mobilizingcs/mobilizr@rc")'
#
## set pam to use blowfish to support the ohmage sync script.
#RUN sed -i 's/pam_unix.so/pam_unix2.so/g' /etc/pam.d/common-*
#RUN sed -i 's/obscure sha512/obscure blowfish/g' /etc/pam.d/common-password
#RUN echo "suppressPackageStartupMessages(library(mobilizr))" > /etc/R/Rprofile.site
##RUN echo "options(defaultPackages = c('datasets', 'utils', 'grDevices', 'graphics', 'stats', 'methods', 'mobilizr'))" > /etc/R/Rprofile.site
#
#RUN echo 'admin-enabled=1' > /etc/rstudio/rserver.conf
#RUN echo 'admin-superuser-group=rstudio-superusers' >> /etc/rstudio/rserver.conf
#RUN echo 'server-multiple-sessions=0' >> /etc/rstudio/rserver.conf
#RUN groupadd rstudio-superusers
#
#ADD run.sh /run.sh
#RUN chmod +x /run.sh
#ADD sync.rb /sync.rb

#VOLUME /var/lib/rstudio-server

EXPOSE 8989

CMD ["ls"]
#CMD ["rsp-license-server", "start"]