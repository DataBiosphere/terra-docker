# Compatibility placeholder for Leonardo. Intentionally contains no settings.
#
# The jupyter configuration for this image lives in jupyter_server_config.py (renamed from this file
# when the image moved to Jupyter Server 2 / Notebook 7, which reads c.ServerApp settings from there).
#
# Leonardo's GCE init script (leonardo: http/src/main/resources/init-resources/gce-init.sh) still runs
#   sed -i '/^# to mount there as it effectively deletes existing files on the image/,+5d' /etc/jupyter/jupyter_notebook_config.py
# before starting Jupyter. That sed is a no-op for current images, but it fails with
# "can't read ... No such file or directory" when this file is missing, which aborts the startup script
# before run-jupyter.sh and the runtime times out. Keep this file until Leonardo drops that line.
#
# Notebook 7 also loads jupyter_notebook_config.* files, so do not add settings here; put them in
# jupyter_server_config.py.
