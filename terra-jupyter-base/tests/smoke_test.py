"""Brief smoke tests for terra-jupyter-base.

Minimal tests simply import packages and run 'hello world' code to determine whether any exceptions
are thrown.

TODO(all): Add additional tests and/or tests with particular assertions, as we encounter Python package version
incompatibilities not currently detected by these tests.
"""

import os
import pytest

def test_firecloud():
  import firecloud

def test_terra-notebook-utils():
  import terra-notebook-utils
  