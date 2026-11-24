#!/bin/bash
# Checks an image against what Leonardo's GCE init and start scripts expect from an image on the
# RStudio code path.
# Example: ./terra-app/tests/contract_test.sh terra-app:smoke-test
set -euo pipefail

IMAGE=${1:-terra-app:smoke-test}

check() {
  local description=$1
  local command=$2
  if docker run --rm --entrypoint /bin/bash "${IMAGE}" -c "${command}"; then
    echo "PASS: ${description}"
  else
    echo "FAIL: ${description}"
    exit 1
  fi
}

check "default user is root" 'test "$(id -u)" = 0'
check "RSTUDIO_HOME is set" 'test -n "${RSTUDIO_HOME:-}"'
check "rstudio user has UID 1000 and is in group users" \
  'test "$(id -u rstudio)" = 1000 && id -nG rstudio | grep -qw users'
check "welder-user has UID 1001" 'test "$(id -u welder-user)" = 1001'
check "rserver.conf exists and can be edited in place" \
  'test -f /etc/rstudio/rserver.conf && sed -i "s/127.0.0.1/0.0.0.0/g" /etc/rstudio/rserver.conf'
check "files under /home/rstudio can be chowned to rstudio:users" \
  'mkdir -p /home/rstudio/.config/rstudio && chown -R rstudio:users /home/rstudio/.config'
check "user script and Renviron folders exist" 'test -d /etc/rstudio/scripts && test -d /usr/local/lib/R/etc'

if docker run --rm "${IMAGE}" > /dev/null 2>&1; then
  echo "FAIL: /init fails when app-start.sh is missing"
  exit 1
fi
echo "PASS: /init fails when app-start.sh is missing"

check "/init runs app-start.sh as rstudio with HOME=/home/rstudio" '
  printf "#!/bin/bash\necho \"\$(id -u):\$(id -gn):\$HOME\"\n" > /etc/terra/app-start.sh
  chmod +x /etc/terra/app-start.sh
  test "$(/init)" = "1000:users:/home/rstudio"'

echo "All terra-app contract checks passed"
