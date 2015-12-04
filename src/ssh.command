#!/bin/bash

#  ssh.command

# get App's Resources folder
res_folder=$(cat ~/coreos-osx/.env/resouces_path)

# ssh into VM
"${res_folder}"/bin/corectl ssh core-01
