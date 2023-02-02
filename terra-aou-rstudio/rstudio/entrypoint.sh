#!/bin/bash

set -e # catches errors

# Run wondershaper to limit network bandwidth to 8mbps down and 4mbps up as
# a different user than RStudio user which is set in the /init script.
su-exec root wondershaper eth0 8096 4048
su-exec root nginx -g 'daemon on;'

# Init must be run as root and will internally handle mapping the end-user
# to UID and GID mapping using S6-overlay
# https://github.com/just-containers/s6-overlay
# using S6
# https://skarnet.org/software/s6/overview.html
/init
