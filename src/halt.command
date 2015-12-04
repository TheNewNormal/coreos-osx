#!/bin/bash

#  halt.command
# stop VM

# get App's Resources folder
res_folder=$(cat ~/coreos-osx/.env/resouces_path)

# get password for sudo
my_password=$(security find-generic-password -wa coreos-osx-app)
# reset sudo
sudo -k
# enable sudo
echo -e "$my_password\n" | sudo -Sv > /dev/null 2>&1

# send halt to VM
sudo "${res_folder}"/bin/corectl halt core-01

# Stop docker registry
"${res_folder}"/docker_registry.sh stop
kill $(ps aux | grep "[r]egistry config.yml" | awk {'print $2'})
