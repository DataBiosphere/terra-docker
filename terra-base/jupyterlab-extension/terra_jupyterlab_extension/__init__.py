try:
    from ._version import __version__
except ImportError:
    # Fallback when using the package in dev mode without installing in editable mode with pip.
    import warnings
    warnings.warn("Importing 'terra_jupyterlab_extension' outside a proper installation.")
    __version__ = "dev"


def _jupyter_labextension_paths():
    return [{"src": "labextension", "dest": "terra-jupyterlab-extension"}]
