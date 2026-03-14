#!/usr/bin/env bash
set -euo pipefail

PORT="${RSTUDIO_PORT:-8001}"

exec /usr/lib/rstudio-server/bin/rserver \
  --server-daemonize=0 \
  --www-port="${PORT}" \
  --auth-none=1 \
  --server-app-armor-enabled=0

