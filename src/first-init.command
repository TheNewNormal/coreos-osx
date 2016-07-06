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
echo "Setting up CoreOS VM on macOS"

# add ssh key to *.toml files
sshkey

# add ssh key to Keychain
if ! ssh-add -l | grep -q ssh/id_rsa; then
    ssh-add -K ~/.ssh/id_rsa &>/dev/null
fi


# Set release channel
release_channel

# create ROOT disk
create_data_disk

# Start docker registry
cd ~/coreos-osx/registry
echo " "
"${res_folder}"/docker_registry.sh start
"${res_folder}"/docker_registry.sh start > /dev/null 2>&1


# Start VM
cd ~/coreos-osx
echo " "
echo "Starting VM ..."
echo " "
#
/usr/local/sbin/corectl load settings/core-01.toml 2>&1 | tee ~/coreos-osx/logs/first-init_vm_up.log
CHECK_VM_STATUS=$(cat ~/coreos-osx/logs/first-init_vm_up.log | grep "started")
#
if [[ "$CHECK_VM_STATUS" == "" ]]; then
    echo " "
    echo "VM have not booted, please check '~/coreos-osx/logs/first-init_vm_up.log' and report the problem !!! "
    echo " "
    pause 'Press [Enter] key to continue...'
    exit 0
else
    echo "VM successfully started !!!" >> ~/coreos-osx/logs/first-init_vm_up.log
fi

# get VM IP
vm_ip=$(/usr/local/sbin/corectl q -i core-01)
# save VM's IP
/usr/local/sbin/corectl q -i core-01 | tr -d "\n" > ~/coreos-osx/.env/ip_address
#

echo " "
# download latest version of docker client
download_osx_clients
#

# Set the environment variables
# set etcd endpoint
export ETCDCTL_PEERS=http://$vm_ip:2379

# docker daemon
export DOCKER_HOST=tcp://$vm_ip:2375
export DOCKER_TLS_VERIFY=
export DOCKER_CERT_PATH=

echo " "
echo " "
echo "Installation has finished, CoreOS VM is up and running !!!"
echo " "
echo "Assigned static IP for VM: $vm_ip"
echo " "
echo "Docker Registry is on: 192.168.64.1:5000 "
echo " "
echo "You can control this App via status bar icon... "
echo " "

#
cd ~/coreos-osx

# open bash shell
/bin/bash



