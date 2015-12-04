#!/bin/bash

# destroy extra disk and create new
#

#
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${DIR}"/functions.sh

# get App's Resources folder
res_folder=$(cat ~/coreos-osx/.env/resouces_path)

# get VM IP
vm_ip=$(<~/coreos-osx/.env/ip_address)

# get password for sudo
my_password=$(security find-generic-password -wa coreos-osx-app)
# reset sudo
sudo -k

LOOP=1
while [ $LOOP -gt 0 ]
do
    VALID_MAIN=0
    echo "VM will be stopped (if running) and destroyed !!!"
    echo "Do you want to continue [y/n]"

    read RESPONSE
    XX=${RESPONSE:=Y}

    if [ $RESPONSE = y ]
    then
        VALID_MAIN=1

        # enable sudo
        echo -e "$my_password\n" | sudo -Sv > /dev/null 2>&1

        # send halt to VM
        sudo "${res_folder}"/bin/corectl halt core-01

        # Stop docker registry
        "${res_folder}"/docker_registry.sh stop
        kill $(ps aux | grep "[r]egistry config.yml" | awk {'print $2'}) > /dev/null 2>&1

        # delete root image
        rm -f ~/coreos-osx/root.img

        # delete password in keychain
        security 2>&1 >/dev/null delete-generic-password -a coreos-osx-app 2>&1 >/dev/null

        echo "-"
        echo "Done, please start VM with 'Up' and the VM will be recreated ..."
        echo " "
        pause 'Press [Enter] key to continue...'
        LOOP=0
    fi

    if [ $RESPONSE = n ]
    then
        VALID_MAIN=1
        LOOP=0
    fi

    if [ $VALID_MAIN != y ] || [ $VALID_MAIN != n ]
    then
        continue
    fi
done
