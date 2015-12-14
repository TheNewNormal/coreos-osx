#!/bin/bash

#  update OS X clients
#

#
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${DIR}"/functions.sh

# get App's Resources folder
res_folder=$(cat ~/coreos-osx/.env/resouces_path)

# get VM's IP
vm_ip=$(cat ~/coreos-osx/.env/ip_address)

# path to the bin folder where we store our binary files
export PATH=${HOME}/coreos-osx/bin:$PATH

# copy files to ~/coreos-osx/bin
cp -f "${res_folder}"/bin/* ~/coreos-osx/bin
chmod 755 ~/coreos-osx/bin/*

# download latest versions of fleetctl and docker clients
download_osx_clients
#

echo " "
echo "Update has finished !!!"
pause 'Press [Enter] key to continue...'

