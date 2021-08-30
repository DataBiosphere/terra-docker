"""Brief smoke tests for terra-jupyter-gatk-ovtf.

Minimal tests simply import packages and run 'hello world' code to determine whether any exceptions
are thrown.

TODO(all): Add additional tests and/or tests with particular assertions, as we encounter Python package version
incompatibilities not currently detected by these tests.
"""

from __future__ import print_function
import os
import pytest

import tensorflow as tf
import openvino_tensorflow


def test_ovtf():
    print("TensorFlow version : ", tf.version.GIT_VERSION, tf.version.VERSION)

    openvino_tensorflow.enable()
    assert openvino_tensorflow.is_enabled() == 1
