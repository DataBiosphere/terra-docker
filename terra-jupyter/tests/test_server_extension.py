import json

import pytest
from tornado.httpclient import HTTPClientError


async def test_terra_config_reads_leonardo_environment(jp_fetch, monkeypatch):
  monkeypatch.setenv('GOOGLE_PROJECT', 'my-project')
  monkeypatch.setenv('CLUSTER_NAME', 'my-runtime')
  monkeypatch.setenv('WELDER_ENABLED', 'true')

  resp = await jp_fetch('api', 'terra', 'config')

  assert json.loads(resp.body) == {
    'googleProject': 'my-project',
    'clusterName': 'my-runtime',
    'welderEnabled': True,
  }


async def test_terra_config_welder_disabled_unless_true(jp_fetch, monkeypatch):
  monkeypatch.setenv('WELDER_ENABLED', 'false')

  resp = await jp_fetch('api', 'terra', 'config')

  assert json.loads(resp.body)['welderEnabled'] is False


async def test_localize_writes_data_uri(jp_fetch, tmp_path, monkeypatch):
  monkeypatch.chdir(tmp_path)
  dest = tmp_path / 'out' / 'hello.txt'

  await jp_fetch('api', 'localize', method='POST',
                 body=json.dumps({str(dest): 'data:text/plain;base64,aGVsbG8='}))

  assert dest.read_text() == 'hello'
  assert (tmp_path / 'localization.log').exists()


async def test_localize_reports_failed_entries(jp_fetch, tmp_path, monkeypatch):
  monkeypatch.chdir(tmp_path)

  with pytest.raises(HTTPClientError) as err:
    await jp_fetch('api', 'localize', method='POST',
                   body=json.dumps({str(tmp_path / 'x'): '/not/a/uri'}))

  assert err.value.code == 500


@pytest.mark.parametrize('body', ['not json', '["a list"]', '{"dest": 1}'])
async def test_localize_rejects_bad_body(jp_fetch, body):
  with pytest.raises(HTTPClientError) as err:
    await jp_fetch('api', 'localize', method='POST', body=body)

  assert err.value.code == 400


async def test_localize_rejects_bad_async_flag(jp_fetch):
  with pytest.raises(HTTPClientError) as err:
    await jp_fetch('api', 'localize', method='POST', body='{}', params={'async': 'maybe'})

  assert err.value.code == 400
