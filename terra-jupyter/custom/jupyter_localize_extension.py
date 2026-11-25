"""Leonardo's Jupyter server extension.

Routes, under the server's base_url:
  POST api/localize     copies gs:// or data: URIs to local paths (used by Terra UI on runtimes
                        without Welder)
  GET  api/terra/config runtime settings for the terra_jupyterlab_extension frontend
"""
import json
import os
import subprocess
import sys

from datauri import DataURI
from jupyter_server.base.handlers import APIHandler
from jupyter_server.utils import url_path_join
from tornado import web
from tornado.ioloop import IOLoop


def _strtobool(value):
  # Replaces distutils.util.strtobool; distutils was removed in Python 3.12.
  lowered = value.lower()
  if lowered in ('y', 'yes', 't', 'true', 'on', '1'):
    return True
  if lowered in ('n', 'no', 'f', 'false', 'off', '0'):
    return False
  raise ValueError(value)


class LocalizeHandler(APIHandler):
  def _sanitize(self, pathstr):
    """Sanitizes paths. Handles local paths, gs: URIs, and data: URIs."""
    # return gs or data uris as is
    if pathstr.startswith("gs:") or pathstr.startswith("data:"):
      return pathstr
    # expand user directories and make intermediate directories
    expanded = os.path.expanduser(pathstr)
    os.makedirs(os.path.dirname(expanded) or '.', exist_ok=True)
    return expanded

  def _localize_gcs_uri(self, locout, source, dest):
    """Localizes an entry where either the source or destination is a gs: path.
    Simply invokes gsutil in a subprocess."""
    # A list of arguments with shell=False lets subprocess handle quoting.
    cmd = ['gsutil', '-m', '-q', 'cp', '-R', '-c', '-e', source, dest]
    locout.write(' '.join(cmd) + '\n')
    result = subprocess.call(cmd, stderr=locout)
    return result == 0

  def _check_gcs_object_status(self, locout, source):
    if not source.startswith("gs:"):
      return True
    source_check = ['gsutil', '-m', '-q', 'ls', source]
    locout.write(' '.join(source_check) + '\n')
    return subprocess.call(source_check, stderr=locout) == 0

  def _localize_data_uri(self, locout, source, dest):
    """Localizes an entry where the source is a data: URI"""
    try:
      uri = DataURI(source)
    except ValueError as e:
      locout.write('Could not parse "{}" as a data URI: {}\n'.format(source, str(e)))
      return False

    try:
      with open(dest, 'w+', buffering=1) as destout:
        try:
          uri_data = uri.data.decode()
        except AttributeError:
          uri_data = uri.data
        destout.write(uri_data)
        locout.write('{}: wrote {} bytes\n'.format(dest, len(uri_data)))
    except IOError as e:
      locout.write('{}: I/O error({}): {}\n'.format(dest, e.errno, e.strerror))
      return False
    except Exception:
      locout.write('{}: unexpected error: {}\n'.format(dest, sys.exc_info()[0]))
      return False

    return True

  def _localize(self, pathdict):
    """Treats the given dict as a string/string map and localizes each entry one by one.
    Returns a list of any failed entries."""
    failures = []
    # This gets dropped inside the user's notebook working directory
    with open("localization.log", 'a', buffering=1) as locout:
      for key in pathdict:
        # NOTE: keys are destinations, values are sources
        source = self._sanitize(pathdict[key])
        dest = self._sanitize(key)

        if source.startswith('gs:') or dest.startswith('gs:'):
          if self._check_gcs_object_status(locout, source):
            success = self._localize_gcs_uri(locout, source, dest)
          else:
            locout.write('Could not validate source or destination: {} -> {}.\n'.format(source, dest))
            success = False
        elif source.startswith('data:'):
          success = self._localize_data_uri(locout, source, dest)
        else:
          locout.write('Unhandled localization entry: {} -> {}. Required gs: or data: URIs.\n'.format(source, dest))
          success = False

        if not success:
          failures.append((dest, source))

    return failures

  @web.authenticated
  async def post(self):
    try:
      pathdict = json.loads(self.request.body)
    except ValueError:
      raise web.HTTPError(400, "Body must be JSON object of type string/string")

    if type(pathdict) is not dict or not all(type(v) is str for v in pathdict.values()):
      raise web.HTTPError(400, "Body must be JSON object of type string/string")

    raw = self.get_query_argument('async', 'false')
    try:
      is_async = _strtobool(raw)
    except ValueError:
      raise web.HTTPError(400, "Could not parse isAsync parameter as a boolean: '{}'".format(raw))

    # gsutil blocks, so run it off the event loop.
    work = IOLoop.current().run_in_executor(None, self._localize, pathdict)

    if is_async:
      # Answer now; the work logs to localization.log in the notebook directory.
      self.set_status(200)
      self.finish()
      return

    failures = await work
    if failures:
      raise web.HTTPError(500, "Error occurred localizing the following {} entries: {}. See localization.log for details.".format(
        len(failures), str(failures)))
    self.set_status(200)
    self.finish()


class TerraConfigHandler(APIHandler):
  """Settings Leonardo passes to the runtime as environment variables."""

  @web.authenticated
  def get(self):
    self.finish(json.dumps({
      'googleProject': os.environ.get('GOOGLE_PROJECT', ''),
      'clusterName': os.environ.get('CLUSTER_NAME', ''),
      # Leonardo sets the string "true" to enable Welder.
      'welderEnabled': os.environ.get('WELDER_ENABLED') == 'true',
    }))


def _jupyter_server_extension_points():
  return [{'module': 'jupyter_localize_extension'}]


def _load_jupyter_server_extension(server_app):
  web_app = server_app.web_app
  base_url = web_app.settings['base_url']
  web_app.add_handlers('.*$', [
    (url_path_join(base_url, '/api/localize'), LocalizeHandler),
    (url_path_join(base_url, '/api/terra/config'), TerraConfigHandler),
  ])
  server_app.log.info('initialized jupyter_localize_extension')


# Name used by jupyter_server's legacy extension loading.
load_jupyter_server_extension = _load_jupyter_server_extension
