#!/bin/bash
# Starts a terra-base container the way Leonardo does and runs browser_smoke_test.py against it
# from a Playwright container on the same Docker network.
# Example: ./terra-base/tests/browser_smoke_test.sh terra-base:smoke-test
set -euo pipefail

IMAGE=${1:-terra-base:smoke-test}
PLAYWRIGHT_IMAGE=mcr.microsoft.com/playwright/python:v1.65.2-noble
NETWORK=terra-base-browser-$$
SERVER=terra-base-$$
WELDER=welder-$$
BASE=/notebooks/test-project/test-runtime
TESTS_DIR=$(cd "$(dirname "$0")" && pwd)

cleanup() {
  docker rm -f "${SERVER}" "${WELDER}" >/dev/null 2>&1 || true
  docker network rm "${NETWORK}" >/dev/null 2>&1 || true
}
trap cleanup EXIT

docker network create "${NETWORK}" >/dev/null
# A stand-in for Welder that accepts every call, so the Welder contents manager can save.
docker run -d --name "${WELDER}" --network "${NETWORK}" --network-alias welder python:3.13-slim python -c '
import http.server
class H(http.server.BaseHTTPRequestHandler):
  def do_POST(self):
    self.rfile.read(int(self.headers.get("Content-Length", 0)))
    self.send_response(200); self.send_header("Content-Type", "application/json"); self.end_headers()
    self.wfile.write(b"{}")
http.server.HTTPServer(("", 8080), H).serve_forever()' >/dev/null
# The extension calls Welder through Leonardo's proxy path on the page origin, which nothing serves
# here, so its metadata check fails and it shows the failure banner. That proves it loaded.
docker run -d --name "${SERVER}" --network "${NETWORK}" --entrypoint tail \
  -e GOOGLE_PROJECT=test-project -e CLUSTER_NAME=test-runtime -e WELDER_ENABLED=true \
  -e NOTEBOOKS_DIR=/home/jupyter -e PYTHONPATH=/etc/jupyter/custom \
  "${IMAGE}" -f /dev/null >/dev/null
docker exec "${SERVER}" /bin/bash -c \
  'echo "{\"cells\": [{\"cell_type\": \"code\", \"source\": \"\", \"metadata\": {}, \"outputs\": [], \"execution_count\": null}], \"metadata\": {\"kernelspec\": {\"name\": \"python3\", \"display_name\": \"Python 3\", \"language\": \"python\"}}, \"nbformat\": 4, \"nbformat_minor\": 5}" > /home/jupyter/test.ipynb'
# Serve the Content-Security-Policy Leonardo's proxy sends (leonardo_csp.txt is a copy of
# contentSecurityPolicy in Leonardo's reference.conf), so policy violations show up in the browser.
docker cp "${TESTS_DIR}/leonardo_csp.txt" "${SERVER}:/tmp/leonardo_csp.txt"
docker exec "${SERVER}" /bin/bash -c "mkdir -p /home/jupyter/.jupyter && cat > /home/jupyter/.jupyter/jupyter_server_config.py" <<'PY'
c = get_config()
c.ServerApp.tornado_settings = {'headers': {'Content-Security-Policy': open('/tmp/leonardo_csp.txt').read().strip()}}
PY
docker exec -d "${SERVER}" /etc/jupyter/scripts/run-jupyter.sh /home/jupyter
for _ in $(seq 1 60); do
  if docker exec "${SERVER}" curl -sf "http://localhost:8000${BASE}/api/status" >/dev/null; then break; fi
  sleep 2
done

docker run --rm --network "${NETWORK}" -v "${TESTS_DIR}:/tests:ro" "${PLAYWRIGHT_IMAGE}" \
  /bin/bash -c "pip install -q playwright==1.65.2 && python /tests/browser_smoke_test.py http://${SERVER}:8000${BASE}"
