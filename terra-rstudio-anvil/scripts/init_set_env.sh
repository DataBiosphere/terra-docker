#!/usr/bin/with-contenv bash
# shellcheck shell=bash

## Set our dynamic variables in Renviron.site to be reflected by RStudio Server or Shiny Server
exclude_vars="HOME PASSWORD RSTUDIO_VERSION BATCH_USER_CREATION"
## Only propagate a safe, explicit allowlist of environment variables into Renviron.site
## to avoid unintentionally persisting secrets.
allowed_vars="PATH LANG LC_ALL LC_CTYPE LC_COLLATE LC_MONETARY LC_MESSAGES LC_NUMERIC LC_TIME TZ R_HOME R_LIBS R_LIBS_SITE R_LIBS_USER R_ENVIRON R_ENVIRON_USER R_ENABLE_JIT R_DEFAULT_PACKAGES"
for file in /var/run/s6/container_environment/*; do
    var_name="${file##*/}"
    sed -i "/^${var_name}=/d" "${R_HOME}/etc/Renviron.site"
    regex="(^| )${var_name}($| )"
    if [[ $allowed_vars =~ $regex ]] && [[ ! $exclude_vars =~ $regex ]]; then
        echo "${var_name}=$(cat "${file}")" >>"${R_HOME}/etc/Renviron.site"
    else
        echo "skipping ${file}"
    fi
done

## ensure Renviron.site is only readable/writable by its owner:
chmod 600 "${R_HOME}/etc/Renviron.site"
## only file-owner (root) should read container_environment files:
chmod 600 /var/run/s6/container_environment/*
