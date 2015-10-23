#!/bin/bash

# console.command
#
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${DIR}"/functions.sh

# get App's Resources folder
res_folder=$(cat ~/coreos-osx/.env/resouces_path)

# Attach to VM's console
echo "Attaching to VM's console ..."
echo " "
"${res_folder}"/bin/dtach -a ~/coreos-osx/.env/.console
