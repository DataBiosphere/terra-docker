# terra_jupyterlab_extension

JupyterLab 4 / Notebook 7 extension for Terra runtimes. It replaces the classic Notebook 6
extensions that `terra-base` 1.x shipped:

- **Edit mode** (was `custom/edit-mode.js`): checks the open notebook with Welder, takes the edit
  lock, shows the Edit / Playground banner, and offers a copy, a reload or playground mode when the
  file is out of sync or locked by another user.
- **Playground mode** (was `custom/safe-mode.js`): hides save, open, new and copy controls when
  the notebook is not in edit mode.
- **Terra UI iframe** (was Terra UI's `public/jupyter-iframe-extension.js`): inside Terra UI's
  iframe, autosaves every 15 s, reports `dirty` / `saved` to the parent page, saves on the parent's
  `save` message, and closes with `close` after shutting the kernel down.

It reads `googleProject`, `clusterName` and `welderEnabled` from the server endpoint
`api/terra/config` (provided by terra-base's server extension), and falls back to parsing the
`/notebooks/{project}/{runtime}/` base URL with Welder disabled.

## Development

```bash
pip install "jupyterlab>=4,<5"   # provides jlpm
jlpm install
jlpm build:prod
jlpm lint:check
jlpm test
pip wheel .                       # builds the prebuilt labextension into the wheel
```
