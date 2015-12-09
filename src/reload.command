#!/bin/bash

#  Reload VM
#
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${DIR}"/functions.sh

# get App's Resources folder
res_folder=$(cat ~/coreos-osx/.env/resouces_path)

# path to the bin folder where we store our binary files
export PATH=${HOME}/coreos-osx/bin:$PATH

# get password for sudo
my_password=$(security find-generic-password -wa coreos-osx-app)
# reset sudo
sudo -k

### Stop VM
echo " "
echo "Stopping VM ..."
# send halt to VM
echo -e "$my_password\n" | sudo -Sv > /dev/null 2>&1
sudo "${res_folder}"/bin/corectl halt core-01

sleep 2

# Start VM
cd ~/coreos-osx
echo " "
echo "Starting VM ..."
echo -e "$my_password\n" | sudo -Sv > /dev/null 2>&1
sudo "${res_folder}"/bin/corectl load settings/core-01.toml
echo " "

# get VM's IP
#vm_ip=$(corectl ps -j | jq ".[] | select(.Name==\"core-01\") | .PublicIP" | sed -e 's/"\(.*\)"/\1/')
vm_ip=$(cat ~/coreos-osx/.env/ip_address);

# set fleetctl endpoint
export FLEETCTL_ENDPOINT=http://$vm_ip:2379
export FLEETCTL_DRIVER=etcd
export FLEETCTL_STRICT_HOST_KEY_CHECKING=false

# get VM's IP
vm_ip=$(<~/coreos-osx/.env/ip_address)

# wait till VM is ready
echo "Waiting for VM to be ready..."
spin='-\|/'
i=0
until curl -o /dev/null http://$vm_ip:2379 >/dev/null 2>&1; do i=$(( (i+1) %4 )); printf "\r${spin:$i:1}"; sleep .1; done
echo " "
#

sleep 2

echo " "
echo "fleetctl list-machines:"
fleetctl list-machines
echo " "

# deploy fleet units from ~/coreos-osx/my_fleet
deploy_my_fleet_units
#

echo "CoreOS VM was reloaded !!!"
echo ""
pause 'Press [Enter] key to continue...'
