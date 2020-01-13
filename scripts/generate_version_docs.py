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

  #filter for images in the conf that have the generate_docs flag set to true
  image_configs = filter(lambda image: image["automated_flags"]["generate_docs"] == True and image["automated_flags"]["include_in_ui"] == True and image["automated_flags"]["build"] == True, config["image_data"])
  remote_docs = get_current_versions()

  #maps the current documentation to a map of {image_name: version} key values
  remote_versions_list = list(map(lambda image_doc: {image_doc["id"]: image_doc["version"]}, remote_docs))
  remote_versions = utils.flatten_list_of_dicts(remote_versions_list)

  print "current versions detected: " + str(remote_versions)

  for image_config in image_configs:
      # Here we check first if the remote documentation exists, then if the local version is the same as the remote. 
      # If the remote documentation exists and the version matches the local, we re-use the old documentation
      if image_config["name"] in remote_versions and image_config["version"] == remote_versions[image_config["name"]]:
        remote_doc = list(filter(lambda image_doc: image_doc["id"] == image_config["name"], remote_docs))[0]
        print "using remote doc: {}".format(remote_doc)
        doc = remote_doc
      else:
        doc = generate_doc_for_image(image_config)

      docs.append(doc)

  docs.append(get_static_legacy_doc())
  return docs

def generate_doc_for_image(image_config):
  version = image_config["version"]
  image_dir = image_config["name"]
  doc = {
    "id": image_dir,
    "label": get_doc_label(image_config),
    "version": version,
    "updated": get_last_updated(image_config),
    "packages": get_doc_link(image_config),
    "image": "{}/{}:{}".format(config['gcr_image_repo'], image_dir, version)
  }

  return doc

def get_doc_label(image_config):
  additional_package_names = image_config["packages"]
  tools = image_config["tools"]
  base_label = image_config["base_label"]
  doc_suffix = config["doc_suffix"]

  package_file = "{}-{}-{}".format(image_config['name'], image_config['version'], doc_suffix)
  utils.gsutil_cp(package_file, config["doc_bucket"], copy_to_remote=False)
  packages = utils.read_json_file(package_file)

  additional_package_labels = []
  for tool in additional_package_names.keys():
    labels = map(lambda package: "{} {}".format(package, packages[tool][package]), additional_package_names[tool])
    additional_package_labels = additional_package_labels + list(labels)

  tool_labels = map(lambda tool: "{} {}".format(tool.capitalize(), packages[tool][tool]), tools)

  labels = list(tool_labels) + list(additional_package_labels)

  label = "{}: ({})".format(base_label,', '.join(labels))

  return label

def get_doc_link(image_config):
  link = "{}/{}/{}-{}-{}".format(config['storage_api'], config['doc_bucket_no_prefix'], image_config["name"], image_config["version"], config['doc_suffix'])
  return link

# will be in YYYY-MM-DD format, which is what terra ui wants
#this function assumes the current version for the image exists in gcr
def get_last_updated(image_config):
  image_repo = config["gcr_image_repo"]
  image_name = image_config["name"]
  version = image_config["version"]
  command = "gcloud container images list-tags {}/{} | grep {} | awk '{{print $NF}}'".format(image_repo, image_name, version)
  ISO8601_date = utils.shell_exec(command)
  terra_date = ISO8601_date.split("T")[0]

  return terra_date

def get_static_legacy_doc():
  doc = {
    "id": 'leonardo-jupyter-dev',
    "label": 'Legacy (default prior to January 14)',
    "version": 'FINAL',
    "updated": '2019-08-26',
    "packages": 'https://storage.googleapis.com/terra-docker-image-documentation/leonardo-jupyter-dev-versions.json',
    "image": 'us.gcr.io/broad-dsp-gcr-public/leonardo-jupyter:5c51ce6935da'
  }

  return doc

def get_current_versions():
  utils.gsutil_cp(config["version_master_file"], config["doc_bucket"], copy_to_remote=False)
  return utils.read_json_file(config["version_master_file"])

if __name__ == "__main__":
  main()
