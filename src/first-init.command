#!/bin/bash

#  first-init.command
#

#
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${DIR}"/functions.sh

# get App's Resources folder
res_folder=$(cat ~/coreos-osx/.env/resouces_path)

# path to the bin folder where we store our binary files
export PATH=${HOME}/coreos-osx/bin:$PATH

echo " "
echo "Setting up CoreOS VM on OS X"

# add ssh key to custom.conf
echo " "
echo "Reading ssh key from $HOME/.ssh/id_rsa.pub ..."
file="$HOME/.ssh/id_rsa.pub"

while [ ! -f "$file" ]
do
    echo "$file not found."
    echo "please run 'ssh-keygen -t rsa' before you continue !!!"
    pause 'Press [Enter] key to continue...'
done

echo " "
echo "$file found, updating custom.conf..."
echo "SSHKEY='$(cat $HOME/.ssh/id_rsa.pub)'" >> ~/coreos-osx/custom.conf
#

# save user password to Keychain
save_password
#

# Set release channel
release_channel

# now let's fetch ISO file
echo " "
echo "Fetching lastest CoreOS $channel channel ISO ..."
echo " "
cd ~/coreos-osx/
"${res_folder}"/bin/coreos-xhyve-fetch -f custom.conf
echo " "
#

# create ROOT disk
create_root_disk

# Stop docker registry first just in case it was running
kill $(ps aux | grep "[r]egistry config.yml" | awk {'print $2'}) >/dev/null 2>&1 &
#

echo " "
# Start VM
echo "Starting VM ..."
"${res_folder}"/bin/dtach -n ~/coreos-osx/.env/.console -z "${res_folder}"/start_VM.command
#

# wait till VM is booted up
echo "You can connect to VM console from menu 'Attach to VM's console' "
echo "When you done with console just close it's window/tab with CMD+W "
echo "Waiting for VM to boot up..."
spin='-\|/'
i=0
until [ -e ~/coreos-osx/.env/.console ] >/dev/null 2>&1; do i=$(( (i+1) %4 )); printf "\r${spin:$i:1}"; sleep .1; done
#
sleep 3

# get VM IP
echo "Waiting for VM to be ready..."
spin='-\|/'
i=0
until cat ~/coreos-osx/.env/ip_address | grep 192.168.64 >/dev/null 2>&1; do i=$(( (i+1) %4 )); printf "\r${spin:$i:1}"; sleep .1; done
vm_ip=$(cat ~/coreos-osx/.env/ip_address)
#
# waiting for VM's response to ping
spin='-\|/'
i=0
while ! ping -c1 $vm_ip >/dev/null 2>&1; do i=$(( (i+1) %4 )); printf "\r${spin:$i:1}"; sleep .1; done
#

echo " "
# download latest versions of etcdctl, fleetctl and docker clients
download_osx_clients
#

# Set the environment variables
# docker daemon
export DOCKER_HOST=tcp://$vm_ip:2375

# set fleetctl endpoint and install fleet units
export FLEETCTL_ENDPOINT=http://$vm_ip:2379
export FLEETCTL_DRIVER=etcd
export FLEETCTL_STRICT_HOST_KEY_CHECKING=false
echo "fleetctl list-machines:"
fleetctl list-machines
echo " "
#
deploy_fleet_units
echo " "
#

echo "Installation has finished, CoreOS VM is up and running !!!"
echo " "
echo "Assigned static VM's IP: $vm_ip"
echo " "
echo "Enjoy CoreOS VM on your Mac !!!"
echo " "
echo "Run from menu 'OS Shell' to open a terminal window with rkt, docker, fleetctl and etcdctl pre-set !!!"
echo " "
echo 'You can close this window/tab with CMD + W'
echo " "

sleep 9000




