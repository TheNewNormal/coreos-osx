#!/bin/bash

# up.command
#

#
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${DIR}"/functions.sh

# create logs dir
mkdir -p ~/coreos-osx/logs > /dev/null 2>&1

# get App's Resources folder
res_folder=$(cat ~/coreos-osx/.env/resouces_path)

# path to the bin folder where we store our binary files
export PATH=${HOME}/coreos-osx/bin:$PATH

# check if iTerm.app exists
App="/Applications/iTerm.app"
if [ ! -d "$App" ]
then
    unzip "${res_folder}"/files/iTerm2.zip -d /Applications/
fi

# copy bin files to bin folder
cp -f "${res_folder}"/bin/* ~/coreos-osx/bin
chmod 755 ~/coreos-osx/bin/*

# copy registry files
cp -f "${res_folder}"/registry/config.yml ~/coreos-osx/registry
cp -f "${res_folder}"/bin/registry ~/coreos-osx/bin
chmod 755 ~/coreos-osx/bin/registry


# add ssh key to Keychain
if ! ssh-add -l | grep -q ssh/id_rsa; then
  ssh-add -K ~/.ssh/id_rsa &>/dev/null
fi
#

# check for password in Keychain
my_password=$(security 2>&1 >/dev/null find-generic-password -wa coreos-osx-app)
if [ "$my_password" = "security: SecKeychainSearchCopyNext: The specified item could not be found in the keychain." ]
then
    echo " "
    echo "Saved password could not be found in the 'Keychain': "
    # save user password to Keychain
    save_password
fi

new_vm=0
# check if data disk exists, if not create it
if [ ! -f $HOME/coreos-osx/data.img ]; then
    echo " "
    echo "Data disk does not exist, it will be created now ..."
    create_data_disk
    new_vm=1
fi

# Stop docker registry first just in case it was running
kill $(ps aux | grep "[r]egistry config.yml" | awk {'print $2'}) >/dev/null 2>&1 &
#

# Start docker registry
cd ~/coreos-osx/registry
echo " "
"${res_folder}"/docker_registry.sh start

# get password for sudo
my_password=$(security find-generic-password -wa coreos-osx-app)
# reset sudo
sudo -k > /dev/null 2>&1

# Start VM
cd ~/coreos-osx
echo " "
echo "Starting VM ..."
echo " "
echo -e "$my_password\n" | sudo -Sv > /dev/null 2>&1
#
sudo "${res_folder}"/bin/corectl load settings/core-01.toml 2>&1 | tee ~/coreos-osx/logs/vm_up.log
CHECK_VM_STATUS=$(cat ~/coreos-osx/logs/vm_up.log | grep "started")
#
if [[ "$CHECK_VM_STATUS" == "" ]]; then
    echo " "
    echo "VM have not booted, please check '~/coreos-osx/logs/vm_up.log' and report the problem !!! "
    echo " "
    pause 'Press [Enter] key to continue...'
    exit 0
else
    echo "VM successfully started !!!" >> ~/coreos-osx/logs/vm_up.log
fi

# check if /Users/homefolder is mounted, if not mount it
"${res_folder}"/bin/corectl ssh core-01 'source /etc/environment; if df -h | grep ${HOMEDIR}; then echo 0; else sudo systemctl restart ${HOMEDIR}; fi' > /dev/null 2>&1

# get VM IP
vm_ip=$("${res_folder}"/bin/corectl q -i core-01)
# save VM's IP
"${res_folder}"/bin/corectl q -i core-01 | tr -d "\n" > ~/coreos-osx/.env/ip_address

# Set the environment variables
# docker daemon
export DOCKER_HOST=tcp://$vm_ip:2375

# set etcd endpoint
export ETCDCTL_PEERS=http://$vm_ip:2379
# wait till VM is ready
echo " "
echo "Waiting for VM to be ready..."
spin='-\|/'
i=1
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
sleep 2

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

sleep 1
#
echo "fleetctl list-units:"
fleetctl list-units
echo " "
#
cd ~/coreos-osx

# open bash shell
/bin/bash
