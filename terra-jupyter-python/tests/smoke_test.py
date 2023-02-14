"""Brief smoke tests for terra-jupyter-python.

Minimal tests simply import packages and run 'hello world' code to determine whether any exceptions
are thrown.

TODO(all): Add additional tests and/or tests with particular assertions, as we encounter Python package version
incompatibilities not currently detected by these tests.
"""

import os
import pytest
import pandas as pd
import numpy as np
import pandas_gbq
import tensorflow as tf
import pysam
from google.oauth2 import service_account

def test_pandas():
  
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
  
# def test_pandas_gbq():

#   sql = """
#   SELECT country_name, alpha_2_code
#   FROM `bigquery-public-data.utility_us.country_code_iso`
#   WHERE alpha_2_code LIKE 'A%'
#   """
#   # Credentials
#   credentials = service_account.Credentials.from_service_account_file('/tmp/credentials.json')
#   print(os.environ['GOOGLE_PROJECT'])
#   pandas_gbq.read_gbq(sql, project_id=os.environ['GOOGLE_PROJECT'], credentials=credentials)
  
def test_tensorflow_gfile():
  
  tf.io.gfile.copy(src='gs://genomics-public-data/1000-genomes/other/sample_info/sample_info.csv',
                   dst='/tmp/genomics-public-data-1000-genomes-sample_info.csv',
                   overwrite=True)

def test_tensorflow_hello_world():
  print("TensorFlow version : ", tf.version.GIT_VERSION, tf.version.VERSION)
  hello = tf.constant('Hello, TensorFlow!')
  tf.print(hello)

def test_pysam():

  # Create BAM file from scratch
  # Code stolen from https://pysam.readthedocs.io/en/latest/usage.html#creating-bam-cram-sam-files-from-scratch
  header = { 'HD': {'VN': '1.0'},
            'SQ': [{'LN': 1575, 'SN': 'chr1'},
                   {'LN': 1584, 'SN': 'chr2'}] }

  file_name = "out.bam"
  with pysam.AlignmentFile(file_name, "wb", header=header) as outf:
    a = pysam.AlignedSegment()
    a.query_name = "read_28833_29006_6945"
    a.query_sequence="AGCTTAGCTAGCTACCTATATCTTGGTCTTGGCCG"
    a.flag = 99
    a.reference_id = 0
    a.reference_start = 32
    a.mapping_quality = 20
    a.cigar = ((0,10), (2,1), (0,25))
    a.next_reference_id = 0
    a.next_reference_start=199
    a.template_length=167
    a.query_qualities = pysam.qualitystring_to_array("<<<<<<<<<<<<<<<<<<<<<:<9/,&,22;;<<<")
    a.tags = (("NM", 1),
              ("RG", "L1"))
    outf.write(a)

  # Verify output file exists
  assert os.path.isfile(file_name)

  # Call samtools to sort the file
  # This will fail if the file is not a valid BAM file
  pysam.sort("-o", "sorted.bam", file_name)
  assert os.path.isfile("sorted.bam")