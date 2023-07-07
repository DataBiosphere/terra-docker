# adapted from https://github.com/jupyter/docker-stacks/blob/master/base-notebook/jupyter_notebook_config.py
# Note: this file also lives in the Leonardo repo here: 
# https://github.com/DataBiosphere/leonardo/blob/develop/http/src/main/resources/jupyter/jupyter_server_config.py
# If you change this please keep the other version consistent as well.

import os

c = get_config()

if os.environ.get('JUPYTER_DEBUG_LOGGING') == 'true':
  c.Application.log_level = 'DEBUG'

c.ServerApp.ip = '0.0.0.0'
c.ServerApp.port = 8000
c.ServerApp.open_browser = False

c.ServerApp.token = ''
c.ServerApp.disable_check_xsrf = True #see https://github.com/nteract/hydrogen/issues/922
c.ServerApp.allow_origin = '*'

c.ServerApp.terminado_settings={'shell_command': ['bash']}

if 'GOOGLE_PROJECT' in os.environ and 'CLUSTER_NAME' in os.environ:
  fragment = '/' + os.environ['GOOGLE_PROJECT'] + '/' + os.environ['CLUSTER_NAME'] + '/'
else:
  fragment = '/'

c.ServerApp.base_url = '/notebooks' + fragment

# This is also specified in run-jupyter.sh
c.ServerApp.nbserver_extensions = {
    'jupyter_localize_extension': True
}

c.ServerApp.kernel_manager_class = 'jupyter_server.services.kernels.kernelmanager.AsyncMappingKernelManager'

mgr_class = 'DelocalizingContentsManager'
if os.environ.get('WELDER_ENABLED') == 'true':
  mgr_class = 'WelderContentsManager'
c.ServerApp.contents_manager_class = 'jupyter_delocalize.' + mgr_class

c.ServerApp.tornado_settings = {
    'static_url_prefix':'/notebooks' + fragment + 'static/'
}
