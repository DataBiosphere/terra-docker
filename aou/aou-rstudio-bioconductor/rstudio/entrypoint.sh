#!/bin/bash

# Run wondershaper to limit network bandwidth to 8mbps down and 4mbps up as
# a different user than RStudio user which is set in the /init script.
su-exec root wondershaper eth0 8096 4048 && nginx -g 'daemon on;'

# Init will handle it's own UID and GID mapping
/init
