#!/bin/bash

# up.command
#

# tidy up after old version
rm -f ~/coreos-osx/.env/password 2>&1 >/dev/null

#
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${DIR}"/functions.sh

# get App's Resources folder
res_folder=$(cat ~/coreos-osx/.env/resouces_path)

# copy xhyve to bin folder
cp -f "${res_folder}"/bin/xhyve ~/coreos-osx/bin
chmod 755 ~/coreos-osx/bin/xhyve

# copy registry files
cp -f "${res_folder}"/registry/config.yml ~/coreos-osx/registry
cp -f "${res_folder}"/bin/registry ~/coreos-osx/bin
chmod 755 ~/coreos-osx/bin/registry

# check for password in Keychain
my_password=$(security 2>&1 >/dev/null find-generic-password -wa coreos-osx-app)
if [ "$my_password" = "security: SecKeychainSearchCopyNext: The specified item could not be found in the keychain." ]
then
    echo " "
    echo "Saved password in 'Keychain' is not found: "
    # save user password to Keychain
    save_password
fi

# Check if set channel's images are present
check_for_images

new_vm=0
# check if root disk exists, if not create it
if [ ! -f $HOME/coreos-osx/root.img ]; then
    echo " "
    echo "ROOT disk does not exist, it will be created now ..."
    create_root_disk
    new_vm=1
fi

# Start VM
rm -f ~/coreos-osx/.env/.console
echo " "
echo "Starting VM ..."
echo " "
"${res_folder}"/bin/dtach -n ~/coreos-osx/.env/.console -z "${res_folder}"/start_VM.command
#

# wait till VM is booted up
echo "You can connect to VM console from menu 'Attach to VM's console' "
echo "When you done with console just close it's window/tab with CMD+W "
echo " "
echo "Waiting for VM to boot up..."
spin='-\|/'
i=0
while [ ! -f ~/coreos-osx/.env/ip_address ]; do i=$(( (i+1) %4 )); printf "\r${spin:$i:1}"; sleep .1; done
# get VM IP
vm_ip=$(cat ~/coreos-osx/.env/ip_address);
# wait for VM to be ready
i=0
while ! ping -c1 $vm_ip >/dev/null 2>&1; do i=$(( (i+1) %4 )); printf "\r${spin:$i:1}"; sleep .1; done

# Set the environment variables
# docker daemon
export DOCKER_HOST=tcp://$vm_ip:2375

# path to the bin folder where we store our binary files
export PATH=${HOME}/coreos-osx/bin:$PATH

# set etcd endpoint
export ETCDCTL_PEERS=http://$vm_ip:2379
# wait till VM is ready
echo " "
echo "Waiting for VM to be ready..."
spin='-\|/'
i=0
until curl -o /dev/null http://$vm_ip:2379 >/dev/null 2>&1; do i=$(( (i+1) %4 )); printf "\r${spin:$i:1}"; sleep .1; done
#
echo " "
echo "etcdctl ls /:"
etcdctl --no-sync ls /
echo " "
#

# set fleetctl endpoint
export FLEETCTL_TUNNEL=
export FLEETCTL_ENDPOINT=http://$vm_ip:2379
export FLEETCTL_DRIVER=etcd
export FLEETCTL_STRICT_HOST_KEY_CHECKING=false
#
sleep 1

echo "fleetctl list-machines:"
fleetctl list-machines
echo " "

# deploy fleet units
if [ $new_vm = 1 ]
then
    deploy_fleet_units
fi

# deploy fleet units from my_fleet folder
deploy_my_fleet_units

#
echo "fleetctl list-units:"
fleetctl list-units
echo " "

#
cd ~/coreos-osx

# open bash shell
/bin/bash
