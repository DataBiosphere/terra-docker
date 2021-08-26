"""Brief smoke tests for terra-jupyter-python.

Minimal tests simply import packages and run 'hello world' code to determine whether any exceptions
are thrown.

TODO(all): Add additional tests and/or tests with particular assertions, as we encounter Python package version
incompatibilities not currently detected by these tests.
"""

import os
import pytest

def test_pandas():
  import pandas as pd
  import numpy as np
  
  pd.DataFrame(
    {
      "A": 1.0,
      "B": pd.Timestamp("20130102"),
      "C": pd.Series(1, index=list(range(4)), dtype="float32"),
      "D": np.array([3] * 4, dtype="int32"),
      "E": pd.Categorical(["test", "train", "test", "train"]),
      "F": "foo",
    }
  )
  
def test_pandas_gbq():
  import pandas_gbq

  sql = """
  SELECT country_name, alpha_2_code
  FROM `bigquery-public-data.utility_us.country_code_iso`
  WHERE alpha_2_code LIKE 'A%'
  """
  pandas_gbq.read_gbq(sql, project_id=os.environ['GOOGLE_PROJECT'])
  
def test_tensorflow_gfile():
  import tensorflow as tf
  
  tf.io.gfile.copy(src='gs://genomics-public-data/1000-genomes/other/sample_info/sample_info.csv',
                   dst='/tmp/genomics-public-data-1000-genomes-sample_info.csv',
                   overwrite=True)
