#!/bin/bash

# up.command
#

#
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${DIR}"/functions.sh


# check if offline setting is present in settings file
check_iso_offline_setting

# check corectld server
check_corectld_server

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

# add ssh key to Keychain
if ! ssh-add -l | grep -q ssh/id_rsa; then
  ssh-add -K ~/.ssh/id_rsa &>/dev/null
fi
#


new_vm=0
# check if data disk exists, if not create it
if [ ! -f $HOME/coreos-osx/data.img ]; then
    echo " "
    echo "CoreOS VM data disk does not exist, it will be created now ..."
    create_data_disk
    new_vm=1
fi
#

# Start VM
cd ~/coreos-osx
echo " "
echo "Starting VM ..."
echo " "
#
cd $HOME/coreos-osx
/usr/local/sbin/corectl load settings/core-01.toml 2>&1 | tee ~/coreos-osx/logs/vm_up.log
#
CHECK_VM_STATUS=$(cat ~/coreos-osx/logs/vm_up.log | grep "started")
#
if [[ "$CHECK_VM_STATUS" == "" ]]; then
    echo " "
    echo "VM has not booted, please check '~/coreos-osx/logs/vm_up.log' and report the problem !!! "
    echo " "
    pause 'Press [Enter] key to continue...'
    exit 0
else
    echo "VM successfully started !!!" >> ~/coreos-osx/logs/vm_up.log
fi

# get VM IP
vm_ip=$(/usr/local/sbin/corectl q -i core-01)
# save VM's IP
/usr/local/sbin/corectl q -i core-01 | tr -d "\n" > ~/coreos-osx/.env/ip_address

# Set the environment variables
# set etcd endpoint
export ETCDCTL_PEERS=http://$vm_ip:2379

# docker daemon
export DOCKER_HOST=tcp://$vm_ip:2375
export DOCKER_TLS_VERIFY=
export DOCKER_CERT_PATH=

#
cd ~/coreos-osx

#
echo " "
echo "Preset CoreOS VM App shell ..."

# open user's preferred shell
if [[ ! -z "$SHELL" ]]; then
    $SHELL
else
    /bin/bash
fi

