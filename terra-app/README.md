# terra-app image

Base image for a single-container web app that runs as a Terra cloud environment (a Leonardo GCE
runtime). Leonardo runs the image through its RStudio code path, so the app is served at
`/proxy/{google-project}/{runtime-name}/rstudio/` and shows as RStudio in Terra UI. The image does
not contain RStudio: it only has the files, users and start hook that Leonardo expects.

Use `us.gcr.io/broad-dsp-gcr-public/terra-app:{version}` as the base of your image.

## Building an app on terra-app

Your image adds the app and an executable `/etc/terra/app-start.sh`. `/init` runs that script as the
`rstudio` user, with `HOME=/home/rstudio`, each time the runtime is created or started. The script
must keep the app in the foreground and serve HTTP on `0.0.0.0:${APP_PORT}` (8001).

```dockerfile
FROM us.gcr.io/broad-dsp-gcr-public/terra-app:0.0.1

COPY my-app /opt/my-app
COPY app-start.sh /etc/terra/app-start.sh
RUN chmod +x /etc/terra/app-start.sh
```

```bash
#!/bin/bash
# app-start.sh
set -euo pipefail
exec /opt/my-app/bin/server --host 0.0.0.0 --port "${APP_PORT}"
```

Things to know:

- Leonardo's proxy removes the `/proxy/{google-project}/{runtime-name}/rstudio` prefix, so the app
  receives requests at `/`. Links the browser follows must still include the prefix.
- `GET /` must return a 2xx response once the app is ready. Leonardo uses it as the health check.
- Environment variables passed in the runtime's `customEnvironmentVariables`, and `GOOGLE_PROJECT`,
  `RUNTIME_NAME` and `OWNER_EMAIL`, are in the container environment.
- The runtime's persistent disk is mounted at `/home/rstudio`. Keep the app's state there.
- Google credentials come from the GCE metadata server, which gives the user's pet service account.
- Do not change the default user from `root`, or the `rstudio` user, UID or group.

## What Leonardo expects

These requirements come from Leonardo's GCE init and start scripts (`gce-init.sh`, `startup.sh`,
`cluster-site-gce.conf`, `HttpDockerDAO.scala`, `HttpRStudioDAO.scala`). `terra-app` provides all of
them except the last two rows, which the app must meet. If Leonardo changes these scripts, update
this table and `tests/contract_test.sh`.

| Requirement | Why Leonardo needs it | If missing |
|---|---|---|
| `ENV RSTUDIO_HOME` (any value) | Detects the tool type when the runtime is created | Request rejected |
| Default user is `root` | Runs `docker exec` without `-u` and edits system files | Init fails |
| `/etc/rstudio/rserver.conf` exists (can be empty) | Runs `sed -i` on it | Init fails |
| User `rstudio` (UID 1000) in group `users`, home `/home/rstudio` | Runs `chown rstudio:users`; mounts the work folder at `/home/rstudio`, shared with Welder (UID 1001) | Init fails |
| `/bin/bash` | Runs all setup commands with `bash -c` | Init fails |
| Executable `/init` | Calls it at create and at each start; the entrypoint is replaced with `tail -f /dev/null` | Runtime goes to Error |
| `/etc/rstudio/scripts/` exists | Copies user startup scripts there | Fails only if a startup script is set |
| `/usr/local/lib/R/etc/` exists | Appends environment variables to `Renviron.site`; errors are ignored | No effect |
| App serves on `0.0.0.0:8001` | The proxy forwards to port 8001 | Runtime goes to Error |
| `GET /` returns 2xx | Health check through the proxy | Runtime goes to Error |

## Testing

```bash
./build_smoke_test_image.sh terra-app
./terra-app/tests/contract_test.sh terra-app:smoke-test
```

To see the complete contents of this image please see the [Dockerfile](./Dockerfile).
