import json 
import subprocess

def write_json_to_file(data, output_name):
  with open(output_name, 'w') as outfile:
    json.dump(data, outfile, indent=4)

def read_json_file(file_name):
  with open(file_name) as json_file:
    data = json.load(json_file)
  
  return data

def gsutil_cp(file, bucket, copy_to_remote=True, debug=True):
  log_name = "gsutil_cp.log"
  base_command = "gsutil cp -L {}".format(log_name)
  if copy_to_remote:
    command = "{} {} {}".format(base_command, file, bucket)
  else:
    command = "{} {}/{} {}".format(base_command, bucket, file, file)

  output = shell_exec(command)

  if debug:
    debug_output_command = "cat {}".format(log_name)
    debug_info = shell_exec(debug_output_command)
    print "printing the output of command {}: \n\t{}".format(command, debug_info)
    

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