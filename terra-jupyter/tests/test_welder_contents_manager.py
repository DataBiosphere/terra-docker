import json

import pytest
import requests_mock as rm
from nbformat.v4 import new_notebook

import jupyter_delocalize

WELDER = 'http://welder:8080'


@pytest.fixture
def manager(tmp_path):
  return jupyter_delocalize.WelderContentsManager(root_dir=str(tmp_path))


@pytest.fixture
def welder():
  with rm.Mocker() as m:
    yield m


def _notebook_model():
  return {'type': 'notebook', 'content': new_notebook()}


def _bodies(welder, path):
  return [json.loads(r.body) for r in welder.request_history if r.path == path]


def test_save_delocalizes_through_welder(manager, welder):
  welder.post(WELDER + '/objects', status_code=200)

  manager.save(_notebook_model(), 'nb.ipynb')

  assert _bodies(welder, '/objects') == [{'action': 'safeDelocalize', 'localPath': 'nb.ipynb'}]
  assert manager.file_exists('nb.ipynb')


def test_save_ignores_unmanaged_files(manager, welder):
  # errorCode 1: no storage link, expected for files outside the workspace folders.
  welder.post(WELDER + '/objects', status_code=412, json={'errorCode': 1})

  manager.save(_notebook_model(), 'scratch.ipynb')

  assert manager.file_exists('scratch.ipynb')


def test_failed_welder_save_reverts_new_file(manager, welder):
  welder.post(WELDER + '/objects', status_code=500, json={'message': 'boom'})

  with pytest.raises(IOError):
    manager.save(_notebook_model(), 'nb.ipynb')

  assert not manager.file_exists('nb.ipynb')


def test_failed_welder_save_reverts_to_previous_content(manager, welder):
  welder.post(WELDER + '/objects', status_code=200)
  original = _notebook_model()
  original['content'].metadata['version'] = 'original'
  manager.save(original, 'nb.ipynb')
  welder.post(WELDER + '/objects', status_code=500, json={'message': 'boom'})
  changed = _notebook_model()
  changed['content'].metadata['version'] = 'changed'

  with pytest.raises(IOError):
    manager.save(changed, 'nb.ipynb')

  assert manager.get('nb.ipynb')['content'].metadata['version'] == 'original'


def test_directories_are_not_sent_to_welder(manager, welder):
  manager.save({'type': 'directory'}, 'dir')

  assert welder.request_history == []


def test_delete_in_edit_mode_deletes_through_welder(manager, welder):
  welder.post(WELDER + '/objects', status_code=200)
  manager.save(_notebook_model(), 'nb.ipynb')
  welder.post(WELDER + '/objects/metadata', json={'syncMode': 'EDIT'})

  manager.delete_file('nb.ipynb')

  assert {'action': 'delete', 'localPath': 'nb.ipynb'} in _bodies(welder, '/objects')
  assert not manager.file_exists('nb.ipynb')


def test_delete_outside_edit_mode_is_local_only(manager, welder):
  welder.post(WELDER + '/objects', status_code=200)
  manager.save(_notebook_model(), 'nb.ipynb')
  welder.post(WELDER + '/objects/metadata', status_code=412)

  manager.delete_file('nb.ipynb')

  assert {'action': 'delete', 'localPath': 'nb.ipynb'} not in _bodies(welder, '/objects')
  assert not manager.file_exists('nb.ipynb')


def test_rename_outside_edit_mode_is_a_local_move(manager, welder):
  welder.post(WELDER + '/objects', status_code=200)
  manager.save(_notebook_model(), 'a.ipynb')
  welder.post(WELDER + '/objects/metadata', status_code=412)

  manager.rename_file('a.ipynb', 'b.ipynb')

  assert manager.file_exists('b.ipynb') and not manager.file_exists('a.ipynb')
