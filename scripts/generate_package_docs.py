from sys import argv
import json
import re
import utils
from collections import ChainMap

config_location = "config/conf.json"

def main():
  params = ParamProcessor(argv)
  write_docs_to_bucket(params)

def write_docs_to_bucket(params):
  docs = get_docs(params)
  file_name = f"{params.image_dir}-{params.image_config['version']}-{params.config['doc_suffix']}"
  utils.write_json_to_file(docs, file_name)
  utils.gsutil_cp(file_name, params.config["doc_bucket"])

def get_docs(params):
  tools = params.image_config["tools"]
  doc_builder = get_doc_builder()

  docs = []
  for tool in tools:
    doc = doc_builder[tool](params)
    docs = docs + doc
  
  #flattens the arrays of objects with package:version key value pairs into single object with all key value pairs
  return dict(ChainMap(*docs))

def get_doc_builder():
  builder = {
    "r": get_r_doc,
    "python": get_python_doc,
    "gatk": get_gatk_doc
  }

  return builder

def get_r_doc(params):
  print(f"writing r doc for {params.image_dir}")
  raw_r_doc =  utils.docker_exec(params.image_dir, "sh -c \"echo 'ip <- as.data.frame(installed.packages()[,c(1,3:4)]) \n rownames(ip) <- NULL \n ip <- ip[is.na(ip\$Priority),1:2,drop=FALSE] \n print(ip, row.names=FALSE)' > temp.r; Rscript temp.r; rm temp.r\"")
  packages = raw_r_doc.strip().split("\n")

  r_version_output = utils.docker_exec(params.image_dir, "R --version | head -1")
  try:
    r_version = re.search("(\d+\.)(\d+\.)(\*|\d+)", r_version_output).group(0)
  except AttributeError as e:
    raise ValueError(f"the R has produced output with an improperly formatted version. Something has likely gone wrong with this script, ensure that the output has a version properly parsed by the regex in the function write_r_doc.\n\tOutput: {r_version_output}")

  package_json = [{"r": r_version}]
  for package in packages[1:]:
    processed_tuple = re.sub(' +', ' ',package.strip()).split(' ')

    assert len(processed_tuple) == 2,f"Asserting format for {package} is correct"
     
    json = { processed_tuple[0]: processed_tuple[1]}
    package_json.append(json)

  return package_json

def get_python_doc(params):
  print(f"writing python doc for {params.image_dir}")
  python_version_output = utils.docker_exec(params.image_dir, "python3 --version")
  raw_python_doc = utils.docker_exec(params.image_dir, "pip list --format=json")

  try:
    python_version = re.search("(\d+\.)(\d+\.)(\*|\d+)", python_version_output).group(0)
  except AttributeError as e:
    raise ValueError(f"the python command has produced output with an improperly formatted version. Something has likely gone wrong with this script, ensure that the output has a version properly parsed by the regex in the function write_python_doc. \n\tOutput: {python_version_output}")

  json_python_doc = json.loads(raw_python_doc)
  json_python_doc = list(map(lambda package: { package["name"]: package["version"] }, json_python_doc))
  json_python_doc.append({"python": python_version})

  return json_python_doc

def get_gatk_doc(params):
  print(f"writing gatk doc for {params.image_dir}")
  cmd = "ls /etc/ | grep gatk | tr '-' ' ' | awk '{print $2}'"
  gatk_version = utils.docker_exec(params.image_dir, cmd)

  return [{"gatk": gatk_version}]

class ParamProcessor():

  def __init__(self, params):
    if not len(params) == 3:
      raise ValueError(f"Usage: python generate_package_docs.py [STRING: image_dir], given: {params}")

    self.image_dir = argv[1]

    self.config = utils.read_json_file(config_location)

    print(f"config: {self.config}")
    print(f"image data:  {self.config['image_data']}")
    
    image_config = list(filter(lambda image_config: image_config["name"] == self.image_dir, self.config["image_data"]))
    if not len(image_config) == 1:
      raise ValueError(f"The image_dir argument must be one of the images in the image_data section of conf.json")

    self.image_config = image_config[0]

if __name__ == '__main__':
  main()