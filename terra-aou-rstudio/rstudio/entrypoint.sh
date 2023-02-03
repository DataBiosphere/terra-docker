#!/bin/bash

set -e # catches errors

# Restrict uploads to 4096 kbit/s (0.512 MB/s) and unlimited download
tc qdisc add dev eth0 root tbf rate 4096kbit latency 50ms burst 1540000

# Init must be run as root and will internally handle mapping the end-user
# to UID and GID mapping using S6-overlay
# https://github.com/just-containers/s6-overlay
# using S6
# https://skarnet.org/software/s6/overview.html
/init
