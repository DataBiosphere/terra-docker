# Jupyter server customizations

- `jupyter_localize_extension.py`: server extension with `api/localize` and `api/terra/config`.
- `jupyter_delocalize.py`: `WelderContentsManager`, which syncs saves, renames and deletes through Welder.
- `*.js`: empty files that Leonardo's init script copies. The frontend is `../jupyterlab-extension`.

Tests are in `../tests` and run in the image: see `../tests/README.md`.
