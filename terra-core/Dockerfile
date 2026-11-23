# Minimal OS layer shared by Terra tool images. No tool, no Python/R/conda, no CUDA.
FROM --platform=linux/amd64 ubuntu:24.04

LABEL maintainer="DSP Analysis Team <dsp-analysis@broadinstitute.org>"

# want the command to fail due to an error at any stage in the pipe: https://github.com/hadolint/hadolint/wiki/DL4006
SHELL ["/usr/bin/bash", "-o", "pipefail", "-c"]

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -yq --no-install-recommends \
    bash \
    ca-certificates \
    curl \
    jq \
    less \
    locales \
    procps \
    sudo \
    # Uncomment en_US.UTF-8 for inclusion in generation
    && sed -i 's/^# *\(en_US.UTF-8\)/\1/' /etc/locale.gen \
    && locale-gen \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENV LC_ALL=en_US.UTF-8

# The Ubuntu base image ships an `ubuntu` user with UID 1000. Remove it so tool images can use
# that UID for their own user.
RUN userdel --remove ubuntu

# This UID must stay consistent with the UID defined in Welder:
# https://github.com/DataBiosphere/welder/blob/master/project/Settings.scala
ENV WELDER_USER=welder-user
ENV WELDER_UID=1001
RUN useradd -m -s /bin/bash -N -u $WELDER_UID $WELDER_USER
