## 0.0.2 - 11/08/2026

Image URL: dockerhub `vjcitn/anvrst462:0.0.2`

- Extends us.gcr.io/broad-dsp-gcr-public/terra-base:1.0.1
- Uses R 4.6.2, RStudio 2026.09.0+174
- Adds BiocManager, tinytex, limma, SpatialFeatureExperiment

### Notes

This command succeeds in presenting RStudio on mac, point browser to localhost:8787, very slow initial startup

```
docker run -ti --rm --platform linux/amd64 -p 8787:8001 vjcitn/anvrst462:0.0.2
```

These messages are encountered:
```
2026-11-08T08:51:37.081953Z [rsession-jupyter] WARNING R version 4.6.2 is newer than the maximum version of R tested with this version of RStudio (4.6.1). If you experience issues, please try updating RStudio to a newer version.; LOGGED FROM: rstudio::core::Error {anonymous}::rInit(const rstudio::r::session::RInitInfo&) src/cpp/session/SessionMain.cpp:611
2026-11-08T08:51:37.091463Z [rsession-jupyter] ERROR system error 2 (No such file or directory) [path: "/usr/local/sbin, path: git]; OCCURRED AT rstudio::core::Error rstudio::core::FilePath::completeChildPath(const string&, rstudio::core::FilePath&) const src/cpp/shared_core/FilePath.cpp:813
2026-11-08T08:51:37.092090Z [rsession-jupyter] ERROR system error 2 (No such file or directory) [path: "/usr/local/sbin, path: svn]; OCCURRED AT rstudio::core::Error rstudio::core::FilePath::completeChildPath(const string&, rstudio::core::FilePath&) const src/cpp/shared_core/FilePath.cpp:813
^C[cont-finish.d] executing container finish scripts...
[cont-finish.d] done.
[s6-finish] waiting for services.
s6-svwait: fatal: timed out
[s6-finish] sending all processes the TERM signal.
TTY detected. Printing informational message about logging configuration. Logging configuration loaded from '/etc/rstudio/logging.conf'. Logging to 'syslog'.
```

