"""Brief smoke tests for terra-jupyter-base.

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

# Re-add this test if one day base image no longer declares `/home/jupyter` as a VOLUME
# toc2 is also not supporting our version of notebook anymore
# def test_extensions():
#   output = subprocess.check_output("jupyter nbextension list", shell=True)
#   if not "toc2/main" in str(output):
#     pytest.fail("toc not enabled") 
    
#   if not "codefolding/main" in str(output):
#     pytest.fail("codefolding not enabled")  

#   if not "collapsible_headings/main" in str(output):
#     pytest.fail("collapsible_headings not enabled")
