#!/bin/bash

#  check VM status
#

# get App's Resources folder
res_folder=$(cat ~/coreos-osx/.env/resouces_path)

# check VM status
status=$(/usr/local/sbin/corectl ps 2>&1 | grep "[c]ore-01")

if [ "$status" = "" ]; then
    echo -n "VM is stopped"
else
    echo -n "VM is running"
fi
