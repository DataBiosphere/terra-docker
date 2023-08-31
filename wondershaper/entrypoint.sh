#!/bin/bash
# Network interface and bandwidth values
INTERFACE="eth0"
UPLOAD_BANDWIDTH="16384"    # kilobits; 16Mib/s (2MiB/s)

# Apply bandwidth limits using Wondershaper
wondershaper -a $INTERFACE -u $UPLOAD_BANDWIDTH

# Keep the container running
tail -f /dev/null

#!/bin/bash
