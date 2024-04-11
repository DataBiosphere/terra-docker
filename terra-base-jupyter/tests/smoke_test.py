"""Brief smoke tests for terra-base-jupyter.

Minimal tests simply import packages and run 'hello world' code to determine whether any exceptions
are thrown.

TODO(all): Add additional tests and/or tests with particular assertions, as we encounter Python package version
incompatibilities not currently detected by these tests.
"""

import os
import pytest
import subprocess

def test_firecloud():
  import firecloud

def test_terra_notebook_utils():
  os.system("gcloud auth application-default login")
  import terra_notebook_utils