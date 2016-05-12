#!/bin/bash

#  Pre-set OS shell
#

# get App's Resources folder
res_folder=$(cat ~/coreos-osx/.env/resouces_path)

# add ssh key to Keychain
ssh-add -K ~/.ssh/id_rsa &>/dev/null

# get VM's IP
vm_ip=$("${res_folder}"/bin/corectl q -i core-01)

# path to the bin folder where we store our binary files
export PATH=${HOME}/coreos-osx/bin:$PATH

# Set the environment variable for the docker daemon
export DOCKER_HOST=tcp://$vm_ip:2375

cd ~/coreos-osx

# open bash shell
/bin/bash
