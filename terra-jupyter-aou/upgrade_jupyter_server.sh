docker exec jupyter-server pip install --upgrade jupyter-server
docker exec -u 0 jupyter-server jupyter server extension enable --py qiime2 --sys-prefix

