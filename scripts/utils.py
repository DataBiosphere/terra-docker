import json 
import subprocess

def write_json_to_file(data, output_name):
  with open(output_name, 'w') as outfile:
    json.dump(data, outfile, indent=4, sort_keys=True)

def read_json_file(file_name):
  with open(file_name) as json_file:
    data = json.load(json_file)
  
  return data

def gsutil_cp(file, bucket, copy_to_remote=True):
  base_command = "gsutil -h 'Cache-Control:no-cache,max-age=0' cp"
  if copy_to_remote:
    command = "{} {} {}".format(base_command, file, bucket)
  else:
    command = "{} {}/{} {}".format(base_command, bucket, file, file)

  output = shell_exec(command)
    

def docker_exec(image_name, command):
  docker_command = "docker exec {} {}".format(image_name, command)
  return shell_exec(docker_command)

def shell_exec(command):
  output = subprocess.check_output(command, shell=True)
  return output.decode('UTF-8').strip()

def flatten_list_of_dicts(l):
  flattened = {}
  [flattened.update(item) for item in l]

  return flattened