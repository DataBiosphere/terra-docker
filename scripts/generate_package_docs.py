from sys import argv
import json
import re
import utils

config_location = "config/conf.json"

def main():
  params = ParamProcessor(argv)
  write_docs_to_bucket(params)

def write_docs_to_bucket(params):
  docs = get_docs(params)
  file_name = "{}-{}-{}".format(params.image_dir, params.image_config['version'], params.config['doc_suffix'])
  utils.write_json_to_file(docs, file_name)
  utils.gsutil_cp(file_name, params.config["doc_bucket"])

def get_docs(params):
  tools = params.image_config["tools"]
  doc_builder = get_doc_builder()

  docs = {}
  for tool in tools:
    print "Writing doc for tool {}".format(tool)
      #flattens the arrays of objects with packages:version key value pairs into single object with all key value pairs
    docs[tool] = utils.flatten_list_of_dicts(doc_builder[tool](params))

  return docs

def get_doc_builder():
  builder = {
    "r": get_r_doc,
    "python": get_python_doc,
    "gatk": get_gatk_doc,
    "spark": get_spark_doc
  }

  return builder

def get_r_doc(params):
  image_dir = params.image_dir
  raw_r_doc =  utils.docker_exec(image_dir, "sh -c \"echo 'ip <- as.data.frame(installed.packages()[,c(1,3:4)]) \n rownames(ip) <- NULL \n ip <- ip[is.na(ip\$Priority),1:2,drop=FALSE] \n print(ip, row.names=FALSE)' > temp.r; Rscript temp.r; rm temp.r\"")
  packages = raw_r_doc.strip().split("\n")

  r_version_output = utils.docker_exec(image_dir, "R --version | head -1")
  try:
    r_version = re.search("(\d+\.)(\d+\.)(\*|\d+)", r_version_output).group(0)
  except AttributeError as e:
    raise ValueError("the R has produced output with an improperly formatted version. Something has likely gone wrong with this script, ensure that the output has a version properly parsed by the regex in the function write_r_doc.\n\tOutput: " + r_version_output)

  bioconductor_version_output = utils.docker_exec(image_dir, "sh -c \"echo 'library(BiocManager) \n BiocManager::version()' > temp2.r; Rscript temp2.r; rm temp2.r\"")
  try:
    bioconductor_version = re.search("(\d+\.)(\d+)", bioconductor_version_output).group(0)
  except AttributeError as e:
    raise ValueError("Biocoductor has produced output with an improperly formatted version. Something has likely gone wrong with this script, ensure that the output has a version properly parsed by the regex in the function write_r_doc.\n\tOutput: " + bioconductor_version_output)

  package_json = [{"r": r_version, "Bioconductor": bioconductor_version}]
  for package in packages[1:]:
    processed_tuple = re.sub(' +', ' ',package.strip()).split(' ')

    assert len(processed_tuple) == 2,"Asserting format for {} is correct".format(package)
     
    json = { processed_tuple[0]: processed_tuple[1]}
    package_json.append(json)

  return package_json

def get_python_doc(params):
  image_dir = params.image_dir
  python_version_output = utils.docker_exec(image_dir, "python3 --version")
  raw_python_doc = utils.docker_exec(image_dir, "pip list --format=json --disable-pip-version-check")

  try:
    python_version = re.search("(\d+\.)(\d+\.)(\*|\d+)", python_version_output).group(0)
  except AttributeError as e:
    raise ValueError("the python command has produced output with an improperly formatted version. Something has likely gone wrong with this script, ensure that the output has a version properly parsed by the regex in the function write_python_doc. \n\tOutput: " + python_version_output)


  json_python_doc = json.loads(raw_python_doc)

  json_python_doc = list(map(lambda package: { package["name"]: package["version"] }, json_python_doc))

  json_python_doc.append({"python": python_version})

  return json_python_doc

def get_gatk_doc(params):
  image_dir = params.image_dir
  cmd = "ls /etc/ | grep gatk | tr '-' ' ' | awk '{print $2}'"
  gatk_version = utils.docker_exec(image_dir, cmd)

  return [{"gatk": gatk_version}]

def get_spark_doc(params):
  return [{"spark": params.config["spark_version"]}]

# defines 3 params
#  image_dir: the name of the image being processed. This is passed from the caller.
#  image_config: the json config associated with the image_dir passed
#  config: the full json config
class ParamProcessor():

  def __init__(self, params):
    if not len(params) == 2:
      raise ValueError("Usage: python generate_package_docs.py [STRING: image_dir], given: " + params)

    self.image_dir = argv[1]

    self.config = utils.read_json_file(config_location)
    
    image_config = list(filter(lambda image_config: image_config["name"] == self.image_dir, self.config["image_data"]))
    if not len(image_config) == 1:
      raise ValueError("The image_dir argument must be one of the images in the image_data section of conf.json")

    self.image_config = image_config[0]

if __name__ == '__main__':
  main()
