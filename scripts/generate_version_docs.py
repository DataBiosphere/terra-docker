import subprocess
import utils

def get_config(path):
  return utils.read_json_file(path)

config_location = "config/conf.json"
config = get_config(config_location)

def main():
  docs = generate_docs()

  utils.write_json_to_file(docs, config["version_master_file"])
  utils.gsutil_cp(config["version_master_file"], config["doc_bucket"])

def generate_docs():
  docs = []
  image_configs = filter(lambda image: image["automated_flags"]["generate_docs"] == True, config["image_data"])

  for image_config in image_configs:
      doc = generate_doc_for_image(image_config)
      docs.append(doc)
    

  docs.append(get_static_legacy_doc())
  return docs

def get_image_dirs():
  image_dirs = []
  
  with open("jenkins/imageDirs.txt") as dir_file:
    for line in dir_file:
      image_dirs.append(line.strip())

  return image_dirs

def generate_doc_for_image(image_config):
  version = image_config["version"]
  image_dir = image_config["name"]
  doc = {
    "label": get_doc_label(image_config, version),
    "version": version,
    "updated": get_last_updated(image_dir),
    "packages": get_doc_link(image_dir),
    "image": f"{config['gcr_image_repo']}/{image_dir}:{version}"
  }

  return doc

def get_doc_label(image_config, version):
  additional_package_names = image_config["packages"]
  tools = image_config["tools"]
  base_label = image_config["base_label"]
  doc_suffix = config["doc_suffix"]

  package_file = f"{image_config['name']}-{version}-{doc_suffix}"
  packages = utils.read_json_file(package_file)

  additional_package_labels = map(lambda package: f"{package} {packages[package]}", additional_package_names) 
  tool_labels = map(lambda tool: f"{tool.capitalize()} {packages[tool]}", tools)

  labels = list(additional_package_labels) + list(tool_labels)

  label = f"{base_label}: ({', '.join(labels)})"

  return label

def get_doc_link(image_dir):
  link = f"{config['storage_api']}/{config['doc_bucket_no_prefix']}/{image_dir}-{config['doc_suffix']}"

  return link

# will be in YYYY-MM-DD format, which is what terra ui wants
def get_last_updated(image_dir):
 command = "git log -1 --pretty='format:%ci' terra-jupyter-base/VERSION | awk '{print $1}'"
 date = subprocess.check_output(command, shell=True)

 return date.decode('UTF-8').strip()

def get_static_legacy_doc():
  doc = {
    "label": 'Default (Python 3.6.8, R 3.5.2, Hail 0.2.11)',
    "version": 'FINAL',
    "updated": '2019-08-26',
    "packages": 'https://storage.googleapis.com/terra-docker-image-documentation/leonardo-jupyter-dev-versions.json',
    "image": 'us.gcr.io/broad-dsp-gcr-public/leonardo-jupyter:5c51ce6935da'
  }

  return doc

if __name__ == "__main__":
  main()



#   export const leoImages = [
#   {
#     label: 'Default (Python 3.6.8, R 3.5.2, Hail 0.2.11)',
#     version: 'FINAL',
#     updated: '2019-08-26',
#     packages: {
#       python: 'https://storage.googleapis.com/terra-docker-image-documentation/leonardo-jupyter-dev-python-packages.txt',
#       r: 'https://storage.googleapis.com/terra-docker-image-documentation/leonardo-jupyter-dev-r-packages.txt',
#       tools: 'https://storage.googleapis.com/terra-docker-image-documentation/leonardo-jupyter-dev-system-packages.txt'
#     },
#     image: 'us.gcr.io/broad-dsp-gcr-public/leonardo-jupyter:5c51ce6935da'
#   },
#   {
#     label: 'Bioconductor (R 3.6.1, Bioconductor 3.9, Tidyverse 1.2.1)',
#     version: '0.0.2',
#     updated: '2019-09-06',
#     packages: {
#       python: 'https://storage.googleapis.com/terra-docker-image-documentation/terra-jupyter-bioconductor-0.0.2-python-packages.txt',
#       r: 'https://storage.googleapis.com/terra-docker-image-documentation/terra-jupyter-bioconductor-0.0.2-r-packages.txt'
#     },
#     image: 'us.gcr.io/broad-dsp-gcr-public/terra-jupyter-bioconductor:0.0.2'
#   }
# ]