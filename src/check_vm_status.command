#!/bin/bash

#  check VM status
#

# get App's Resources folder
res_folder=$(cat ~/coreos-osx/.env/resouces_path)

# path to the bin folder where we store our binary files
export PATH=${HOME}/coreos-osx/bin:$PATH

# check VM status
status=$(corectl ps -j | "${res_folder}"/bin/jq ".[] | select(.Name==\"core-01\") | .Detached")

if [ "$status" = "" ]; then
    echo -n "VM is Off"
else
    echo -n "VM is running"
fi
