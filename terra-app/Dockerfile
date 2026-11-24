# Base for single-container web apps that run on a Leonardo GCE runtime through the RStudio code
# path. It has no tool of its own: child images add their app and /etc/terra/app-start.sh.
# See README.md for what Leonardo expects from this image.
FROM us.gcr.io/broad-dsp-gcr-public/terra-core:0.0.1

LABEL maintainer="DSP Analysis Team <dsp-analysis@broadinstitute.org>"

# Leonardo detects the tool type from this variable; any value works.
ENV RSTUDIO_HOME=/etc/rstudio
# Port Leonardo's proxy forwards to.
ENV APP_PORT=8001

# Leonardo mounts the runtime's work folder at /home/rstudio and chowns files there to
# rstudio:users, so the user, UID and group must stay as they are.
RUN useradd -m -s /bin/bash -d /home/rstudio -N -g users -u 1000 rstudio \
    && mkdir -p $RSTUDIO_HOME/scripts /usr/local/lib/R/etc /etc/terra \
    && touch $RSTUDIO_HOME/rserver.conf

COPY init /init
RUN chmod 0755 /init

# Leonardo runs its setup commands with `docker exec` as the image's default user and edits
# system files, so this must stay root. /init drops to the rstudio user.
USER root
WORKDIR /home/rstudio

# Leonardo replaces the entrypoint and calls /init itself with `docker exec`.
ENTRYPOINT ["/init"]
