import json 
import subprocess

def write_json_to_file(data, output_name):
  with open(output_name, 'w') as outfile:
    json.dump(data, outfile, indent=4)

def read_json_file(file_name):
  with open(file_name) as json_file:
    data = json.load(json_file)
  
  return data

def gsutil_cp(file, bucket):
 command = f"gsutil cp {file} {bucket}"
 subprocess.run(command, shell=True)

def docker_exec(image_name, cmd):
  command = f"docker exec {image_name} {cmd}"

  output = subprocess.check_output(command, shell=True)
  return output.decode('UTF-8').strip()

  return data