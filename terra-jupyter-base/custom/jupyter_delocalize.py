from datetime import timedelta
import json
import os
import requests
import tornado
from notebook.services.contents.largefilemanager import LargeFileManager

METADATA_TTL = timedelta(minutes=5)

class WelderContentsManager(LargeFileManager):
  """
  A contents manager which integrates with the Leo Welder service.

  Blocking Welder API calls are made before files are persisted. After a
  successful call to Welder, files are persisted to the local Jupyter file
  system as usual.
  """

  def __init__(self, *args, **kwargs):
    # This log line shouldn't be necessary, but Jupyter's built-in logging is
    # lacking and its configuration can be complex. Having this in the server
    # logs is useful for confirming which ContentsManager is in use.
    self.log.info('initializing WelderContentsManager')
    self.welder_base_url = 'http://welder:8080'
    super(WelderContentsManager, self).__init__(*args, **kwargs)

  def _extract_welder_error(self, resp):
    try:
      return json.dumps(resp.json())
    except:
      return resp.reason or 'unknown Welder error'

  def _is_nonempty_dir(self, path):
    os_path = self._get_os_path(path)
    return os.path.isdir(os_path) and len(os.listdir(os_path)) > 0


  def _check_welder_edit_mode(self, path):
    resp = requests.post(self.welder_base_url + '/objects/metadata', data=json.dumps({
      # Sometimes the Jupyter UI provided "path" contains a leading /, sometimes
      # not; strip for Welder.
      'localPath': path.lstrip('/')
    }))
    if resp.status_code == 412:
      return False

    if not resp.ok:
      raise IOError("checkMetadata failed: '{}'".format(self._extract_welder_error(resp)))

    return resp.json().get("syncMode") == "EDIT"


  def _post_welder(self, action, path):
    # Ignore storage link failure, throw other errors.
    resp = requests.post(self.welder_base_url + '/objects', data=json.dumps({
      'action': action,
      # Sometimes the Jupyter UI provided "path" contains a leading /, sometimes
      # not; strip for Welder.
      'localPath': path.lstrip('/')
    }))
    if not resp.ok:
      error_json = {}
      try:
        error_json = resp.json()
      except:
        pass

      # See https://github.com/DataBiosphere/welder/blob/cd39caba30989e9f2b1c76986abccf22d8e8a1c5/server/src/main/resources/api-docs.yaml#L197
      ignore_codes = set([
          1, # Storage Link not found; expected for unmanaged files.
          2, 3 # Delocalize/delete safe mode file; expected in safe mode directories.
      ])
      if resp.status_code == 412 and error_json.get('errorCode', -1) in ignore_codes:
        return

      raise IOError("welder action '{}' failed: '{}'".format(action, self._extract_welder_error(resp)))

  def save(self, model, path=''):
    # Don't intefere with intermediate chunks during multipart upload:
    # https://jupyter-notebook.readthedocs.io/en/stable/extending/contents.html#chunked-saving
    if model.get("chunk", -1) >= 0:
      return super(WelderContentsManager, self).save(model, path)

    # Capture the pre-save file so we can revert if Welder fails.
    orig_model = None
    try:
      orig_model = self.get(path)
    except tornado.web.HTTPError as err:
      if err.status_code != 404:
        self.log.warn('failed to get file "{}", cannot revert: {}'.format(path, err.log_message))

    # Welder reads the file from local disk, so we need to write the updated file
    # before calling Welder.
    # TODO(calbach): Consider changing the safeDelocalize API to support either
    # direct passing of contents, or passing a file via a temporary transfer file.
    ret = super(WelderContentsManager, self).save(model, path)
    if not path or model['type'] == 'directory':
      return ret

    try:
      self._post_welder('safeDelocalize', path)
    except IOError as werr:
      self.log.warn("welder save failed, attempting to revert local file: " + str(werr))
      try:
        if orig_model:
          super(WelderContentsManager, self).save(orig_model, path)
        else:
          super(WelderContentsManager, self).delete_file(path)
      except Exception as rerr:
        self.log.error("failed to revert after Welder error, local disk is in an inconsistent state: " + str(rerr))
      raise werr
    return ret

  def rename_file(self, old_path, new_path):
    from_edit_mode = self._check_welder_edit_mode(old_path)
    to_edit_mode = self._check_welder_edit_mode(new_path)
    if not from_edit_mode and not to_edit_mode:
      # If we're not touching any edit mode files, just do a normal move.
      return super(WelderContentsManager, self).rename_file(old_path, new_path)

    if self._is_nonempty_dir(old_path):
      raise NotImplementedError("renaming of non-empty edit mode directories is not supported")

    # These methods already properly handle edit mode semantics.
    self.save(self.get(old_path), new_path)
    try:
      self.delete_file(old_path, from_edit_mode)
    except Exception as err:
      self.log.error("failed to delete old file during two-phase rename, " +
          "attempting to revert save from the first phase: " + str(err))
      try:
        self.delete_file(new_path, to_edit_mode)
      except Exception as rerr:
        self.log.error("failed to revert first phase of rename via delete, " +
            "extra file will remain on disk and/or GCS: " + str(rerr))
        raise rerr
      raise err

  def delete_file(self, path, edit_mode=None):
    if edit_mode is None:
      edit_mode = self._check_welder_edit_mode(path)

    if edit_mode:
      if self._is_nonempty_dir(path):
        raise NotImplementedError("deletion of non-empty edit mode directories is not supported")
      self._post_welder('delete', path)

    super(WelderContentsManager, self).delete_file(path)
