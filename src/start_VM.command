#!/bin/bash

# Start VM
#
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${DIR}"/functions.sh

# get App's Resources folder
res_folder=$(cat ~/coreos-osx/.env/resouces_path)

# Get UUID
UUID=$(cat ~/coreos-osx/custom.conf | grep UUID= | head -1 | cut -f2 -d"=")

# Get password
my_password=$(security find-generic-password -wa coreos-osx-app)

# Get mac address and save it
echo -e "$my_password\n" | sudo -S "${res_folder}"/bin/uuid2mac $UUID > ~/coreos-osx/.env/mac_address

# Get VM's IP and save it to file
"${res_folder}"/bin/get_ip &

# Start webserver
cd ~/coreos-osx/cloud-init
"${res_folder}"/bin/webserver start
"${res_folder}"/bin/webserver start

# Start docker registry
cd ~/coreos-osx/registry
"${res_folder}"/bin/docker_registry start

# Start VM
echo "Waiting for VM to boot up... "
cd ~/coreos-osx
export XHYVE=~/coreos-osx/bin/xhyve
"${res_folder}"/bin/coreos-xhyve-run -f custom.conf coreos-osx

# Stop webserver
"${res_folder}"/bin/webserver stop

# Stop docker registry
kill $(ps aux | grep "[r]egistry config.yml" | awk {'print $2'})
