"""Brief smoke tests for terra-jupyter-python.

Minimal tests simply import packages and run 'hello world' code to determine whether any exceptions
are thrown.

TODO(all): Add additional tests and/or tests with particular assertions, as we encounter Python package version
incompatibilities not currently detected by these tests.
"""

import os
import pytest

def test_terra_widgets():
  from terra_widgets.html_snapshots import display_html_snapshots_widget
