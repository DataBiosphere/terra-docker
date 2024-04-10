from jupyter_delocalize import WelderContentsManager

c.ServerApp.quit_button=False
c.ServerApp.certfile=''
c.ServerApp.keyfile=''
c.ServerApp.port=8888
c.ServerApp.token=''
c.ServerApp.ip=''
c.ServerApp.allow_origin="*"
c.ServerApp.disable_check_xsrf=True # to prevent 'xsrf missing from POST' error https://broadworkbench.atlassian.net/browse/IA-4284
c.KernelSpecManager.ensure_native_kernel = False # Hide the default python3 kernel that jupyter is running in to isolate from the user
c.ServerApp.terminado_settings = {'shell_command': ['/usr/bin/bash']}
c.ServerApp.contents_manager_class=WelderContentsManager