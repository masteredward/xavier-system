#!/usr/bin/env python3

from sys import argv
from python_on_whales import docker
from yaml import safe_load

def load_yaml():
  return safe_load(
    open(
      "/sources/xv.yaml",
      "r",
      encoding="utf-8"
    )
  )

def build_image(image):
  docker.build(
    f"/sources/{image}/",
    tags=[image]
  )

def dedup_list(item_list):
  return [
    i for n,
    i in enumerate(item_list) if i not in item_list[n + 1:]
  ]

def get_ports(config, image):
  ports = dedup_list(
    list(
      config["shared"]["ports"] + config["containers"][image]["ports"]
    )
  )
  result = list()
  for port in ports:
    result.append(
      (
        port["host"],
        port["container"],
        port["protocol"]
      )
    )
  return result

def get_envs(config, image):
  envs = dedup_list(
    list(
      config["shared"]["environment"] + config["containers"][image]["environment"]
    )
  )
  result = dict()
  for env in envs:
    result[env["name"]] = env["value"]
  return result

def get_vols(config, image):
  vols = dedup_list(
    list(
      config["shared"]["volumes"] + config["containers"][image]["volumes"]
    )
  )
  result = []
  for vol in vols:
    result.append(
      (
        vol["source"],
        vol["target"],
        vol["mode"]
      )
    )
  return result

def run_image(config, image):
  return docker.run(
    image,
    name="xv-container",
    hostname=image,
    detach=True,
    restart="unless-stopped",
    publish=get_ports(config, image),
    envs=get_envs(config, image),
    volumes=get_vols(config, image)
  )

def remove_container():
  docker.remove(
    "xv-container",
    force=True,
    volumes=True
  )

def main():
  config = load_yaml()
  image = argv[1]
  build_image(image)
  try: 
    remove_container()
  except:
    print("No container running to stop.")
    pass
  print(f"New container ID: {run_image(config, image)}")

if __name__=="__main__":
  main()
