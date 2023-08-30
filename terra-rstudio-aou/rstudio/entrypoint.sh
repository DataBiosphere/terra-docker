#!/bin/bash

set -e # catches errors

pushd /usr/local/share/wondershaper
wondershaper -a "eth0" -u 16384 # kilobits; 16Mib/s (2MiB/s)

popd

# Init must be run as root and will internally handle mapping the end-user
# to UID and GID mapping using S6-overlay
# https://github.com/just-containers/s6-overlay
# using S6
# https://skarnet.org/software/s6/overview.html
exec /init
