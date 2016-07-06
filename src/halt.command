#!/bin/bash

#  halt.command

# get App's Resources folder
res_folder=$(cat ~/coreos-osx/.env/resouces_path)

# path to the bin folder where we store our binary files
export PATH=${HOME}/coreos-osx/bin:$PATH

# send halt to VM
/usr/local/sbin/corectl halt core-01

# Stop docker registry
"${res_folder}"/docker_registry.sh stop
kill $(ps aux | grep "[r]egistry config.yml" | awk {'print $2'}) >/dev/null 2>&1
