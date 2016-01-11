#!/bin/bash

#  update OS X clients
#

#
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${DIR}"/functions.sh

# get App's Resources folder
res_folder=$(cat ~/coreos-osx/.env/resouces_path)

# get VM's IP
vm_ip=$("${res_folder}"/bin/corectl q -i core-01)

# path to the bin folder where we store our binary files
export PATH=${HOME}/coreos-osx/bin:$PATH
# docker daemon
export DOCKER_HOST=tcp://$vm_ip:2375

# copy files to ~/coreos-osx/bin
cp -f "${res_folder}"/bin/* ~/coreos-osx/bin
chmod 755 ~/coreos-osx/bin/*

# download latest versions of fleetctl and docker clients
osx_clients_upgrade=0
download_osx_clients
if [ $osx_clients_upgrade -eq 0 ]; then
    echo " "
else
    echo " "
    echo "Update has finished !!!"
    echo " "
fi
#

pause 'Press [Enter] key to continue...'

