#!/bin/bash

#  check VM status
#

# get App's Resources folder
res_folder=$(cat ~/coreos-osx/.env/resouces_path)

# check VM status
status=$("${res_folder}"/bin/corectl ps -j | "${res_folder}"/bin/jq ".[] | select(.Name==\"core-01\") | .Detached")

if [ "$status" = "" ]; then
    echo -n "VM is stopped"
else
    echo -n "VM is running"
fi
