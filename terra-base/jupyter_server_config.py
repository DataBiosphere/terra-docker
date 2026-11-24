# Server settings for Terra runtimes. Leonardo proxies the server at /notebooks/{project}/{runtime}/.
# Note: this file also lives in the Leonardo repo here:
# https://github.com/DataBiosphere/leonardo/blob/develop/http/src/main/resources/jupyter/jupyter_notebook_config.py
# If you change this please keep the other version consistent as well.

import os

c = get_config()

if os.environ.get('JUPYTER_DEBUG_LOGGING') == 'true':
  c.Application.log_level = 'DEBUG'

c.ServerApp.ip = '0.0.0.0'
c.ServerApp.port = 8000
c.ServerApp.open_browser = False

# Leonardo's proxy authenticates users; the server itself is not exposed.
c.IdentityProvider.token = ''
c.ServerApp.disable_check_xsrf = True  # see https://github.com/nteract/hydrogen/issues/922
c.ServerApp.allow_origin = '*'

c.ServerApp.terminado_settings = {'shell_command': ['bash']}

if 'GOOGLE_PROJECT' in os.environ and 'CLUSTER_NAME' in os.environ:
  fragment = '/' + os.environ['GOOGLE_PROJECT'] + '/' + os.environ['CLUSTER_NAME'] + '/'
else:
  fragment = '/'

c.ServerApp.base_url = '/notebooks' + fragment
c.ServerApp.default_url = '/tree'

# Without Welder, files are only saved locally.
if os.environ.get('WELDER_ENABLED') == 'true':
  c.ServerApp.contents_manager_class = 'jupyter_delocalize.WelderContentsManager'
else:
  c.ServerApp.contents_manager_class = 'jupyter_server.services.contents.largefilemanager.LargeFileManager'

# so that the default kernel can be overridden by the conda environment
c.KernelSpecManager.ensure_native_kernel = False
