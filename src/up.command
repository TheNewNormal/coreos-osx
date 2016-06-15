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
#

# Start docker registry
cd ~/coreos-osx/registry
echo " "
"${res_folder}"/docker_registry.sh start
"${res_folder}"/docker_registry.sh start > /dev/null 2>&1

# get password for sudo
my_password=$(security find-generic-password -wa coreos-osx-app)
# reset sudo
sudo -k > /dev/null 2>&1

# start corectl server
###sudo /usr/local/sbin/corectl server -u $USER --start >/dev/null 2>&1 &
#sudo /usr/local/sbin/corectl server --start

# Start VM
cd ~/coreos-osx
echo " "
echo "Starting VM ..."
echo " "
echo -e "$my_password\n" | sudo -Sv > /dev/null 2>&1
#
cd $HOME/coreos-osx
/usr/local/sbin/corectl load settings/core-01.toml 2>&1 | tee ~/coreos-osx/logs/vm_up.log
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
/usr/local/sbin/corectl ssh core-01 'source /etc/environment; if df -h | grep ${HOMEDIR}; then echo 0; else sudo systemctl restart ${HOMEDIR}; fi' > /dev/null 2>&1

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

echo " "
#
cd ~/coreos-osx

# open bash shell
/bin/bash
