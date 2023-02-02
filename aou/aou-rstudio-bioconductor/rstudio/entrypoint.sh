#!/bin/bash
su-exec root wondershaper eth0 8096 4048 && nginx -g 'daemon on;'
# Init will handle it's own UID and GID mapping
/init
