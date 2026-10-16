# adapted from https://github.com/jupyter/docker-stacks/blob/master/base-notebook/jupyter_notebook_config.py
# Note: this file also lives in the Leonardo repo here:
# https://github.com/DataBiosphere/leonardo/blob/develop/http/src/main/resources/jupyter/jupyter_notebook_config.py
# If you change this please keep the other version consistent as well.
#
# Renamed from jupyter_notebook_config.py and ported from c.NotebookApp to c.ServerApp:
# Notebook 7 runs on Jupyter Server, which only reads jupyter_server_config.py and no
# longer defines the NotebookApp traits. Under the old name/class these settings were
# silently dropped and the server came up on a random loopback port with a random token.

import os

c = get_config()

if os.environ.get('JUPYTER_DEBUG_LOGGING') == 'true':
  c.Application.log_level = 'DEBUG'

c.ServerApp.ip = '0.0.0.0'
c.ServerApp.port = 8000
c.ServerApp.open_browser = False

# ServerApp.token is deprecated in jupyter-server 2.x in favor of the identity provider
c.IdentityProvider.token = ''
c.ServerApp.disable_check_xsrf = True #see https://github.com/nteract/hydrogen/issues/922
c.ServerApp.allow_origin = '*'

c.ServerApp.terminado_settings={'shell_command': ['bash']}

if 'GOOGLE_PROJECT' in os.environ and 'CLUSTER_NAME' in os.environ:
  fragment = '/' + os.environ['GOOGLE_PROJECT'] + '/' + os.environ['CLUSTER_NAME'] + '/'
else:
  fragment = '/'

c.ServerApp.base_url = '/notebooks' + fragment

# This is also specified in run-jupyter.sh
c.ServerApp.jpserver_extensions = {
    'jupyter_localize_extension': True
}

# Only override the contents manager when Welder is in play. The old non-Welder
# default, jupyter_delocalize.DelocalizingContentsManager, was removed in #252 and
# naming it here makes jupyter-server fail at startup with
# "'jupyter_delocalize.DelocalizingContentsManager' could not be imported".
# Without Welder, jupyter-server's own AsyncLargeFileManager is the right default.
if os.environ.get('WELDER_ENABLED') == 'true':
  c.ServerApp.contents_manager_class = 'jupyter_delocalize.WelderContentsManager'

c.ServerApp.tornado_settings = {
    'static_url_prefix':'/notebooks' + fragment + 'static/'
}

# The classic UI (nbclassic, at /nbclassic) is configured through c.NotebookApp, which Notebook 7 no
# longer reads. Its bundled MathJax 2.7.9 is removed from the image (GHSA-v638-q856-grg8), so don't load
# it: LaTeX shows as plain text in the classic UI. Notebook 7 and JupyterLab render math with MathJax 3.
c.NotebookApp.enable_mathjax = False

# so that the default kernel can be overridden by the conda environment
c.KernelSpecManager.ensure_native_kernel = False
