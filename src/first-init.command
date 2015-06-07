#!/bin/bash

#  first-init.command
#  CoreOS GUI for OS X
#
#  Created by Rimantas on 01/04/2014.
#  Copyright (c) 2014 Rimantas Mocevicius. All rights reserved.

### Enable shared folder
LOOP=1
while [ $LOOP -gt 0 ]
do
    VALID_MAIN=0
    echo "Do you want to enable NFS shared local folder '~/coreos-osx/share' to CoreOS VM '/home/coreos/share' one? [y/n]"

    read RESPONSE
    XX=${RESPONSE:=Y}

    if [ $RESPONSE = y ]
    then
        VALID_MAIN=1
        # enable shared folder
        sed -i "" 's/##$shared_folders/$shared_folders/' ~/coreos-osx/coreos-vagrant/config.rb

        # update /etc/sudoers file
        echo "(You will be asked for your OS X user password !!!)"
        CHECK_SUDOERS=$(sudo -s 'cat /etc/sudoers | grep "# Added by CoreOS GUI App"')
        if [ "$CHECK_SUDOERS" = "" ]
        then
            echo "Updating /etc/sudoers file"
            sudo -s 'cat ~/coreos-osx/tmp/sudoers >> /etc/sudoers'
        else
            echo "You already have in /etc/sudoers '# Added by CoreOS GUI App' lines !!!"
            echo "Please double check /etc/sudoers file for it and delete all lines starting # Added by CoreOS GUI App - start' !!!"
            echo "inclusevely lines with # Added by CoreOS GUI App too "
            echo "and add the entry shown below !!!"
            cat ~/coreos-osx/tmp/sudoers
        fi
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

# remove temporal files
rm -f ~/coreos-osx/tmp/*

### Enable shared folder

### Set release channel
LOOP=1
while [ $LOOP -gt 0 ]
do
    VALID_MAIN=0
    echo " "
    echo " Set CoreOS Release Channel:"
    echo " 1)  Alpha "
    echo " 2)  Beta "
    echo " 3)  Stable "
    echo " "
    echo "Select an option:"

    read RESPONSE
    XX=${RESPONSE:=Y}

    if [ $RESPONSE = 1 ]
    then
        VALID_MAIN=1
        sed -i "" 's/#$update_channel/$update_channel/' ~/coreos-osx/coreos-vagrant/config.rb
        sed -i "" "s/channel='stable'/channel='alpha'/" ~/coreos-osx/coreos-vagrant/config.rb
        sed -i "" "s/channel='beta'/channel='alpha'/" ~/coreos-osx/coreos-vagrant/config.rb
        # enable etcd2
        sed -i "" "s/etcd.service/etcd2.service/" ~/coreos-osx/coreos-vagrant/user-data
        LOOP=0
    fi

    if [ $RESPONSE = 2 ]
    then
        VALID_MAIN=1
        sed -i "" 's/#$update_channel/$update_channel/' ~/coreos-osx/coreos-vagrant/config.rb
        sed -i "" "s/channel='alpha'/channel='beta'/" ~/coreos-osx/coreos-vagrant/config.rb
        sed -i "" "s/channel='stable'/channel='beta'/" ~/coreos-osx/coreos-vagrant/config.rb
        # enable etcd2
        sed -i "" "s/etcd.service/etcd2.service/" ~/coreos-osx/coreos-vagrant/user-data
        LOOP=0
    fi

    if [ $RESPONSE = 3 ]
    then
        VALID_MAIN=1
        sed -i "" 's/#$update_channel/$update_channel/' ~/coreos-osx/coreos-vagrant/config.rb
        sed -i "" "s/channel='alpha'/channel='stable'/" ~/coreos-osx/coreos-vagrant/config.rb
        sed -i "" "s/channel='beta'/channel='stable'/" ~/coreos-osx/coreos-vagrant/config.rb
        # enable etcd
        sed -i "" "s/etcd2.service/etcd.service/" ~/coreos-osx/coreos-vagrant/user-data
        LOOP=0
    fi

    if [ $VALID_MAIN != 1 ]
    then
        continue
    fi
done
### Set release channel


function pause(){
read -p "$*"
}

# first up to initialise VM
echo "Setting up Vagrant VM for CoreOS on OS X"
cd ~/coreos-osx/coreos-vagrant
vagrant box update
vagrant up --provider virtualbox

# Add vagrant ssh key to ssh-agent
##vagrant ssh-config core-01 | sed -n "s/IdentityFile//gp" | xargs ssh-add
ssh-add ~/.vagrant.d/insecure_private_key >/dev/null 2>&1

# download etcdctl and fleetctl
#
cd ~/coreos-osx/coreos-vagrant
LATEST_RELEASE=$(vagrant ssh -c "etcdctl --version" | cut -d " " -f 3- | tr -d '\r' )
cd ~/coreos-osx/bin
echo "Downloading etcdctl $LATEST_RELEASE for OS X"
curl -L -o etcd.zip "https://github.com/coreos/etcd/releases/download/v$LATEST_RELEASE/etcd-v$LATEST_RELEASE-darwin-amd64.zip"
unzip -j -o "etcd.zip" "etcd-v$LATEST_RELEASE-darwin-amd64/etcdctl"
rm -f etcd.zip
#
cd ~/coreos-osx/coreos-vagrant
LATEST_RELEASE=$(vagrant ssh -c 'fleetctl version' | cut -d " " -f 3- | tr -d '\r')
cd ~/coreos-osx/bin
echo "Downloading fleetctl v$LATEST_RELEASE for OS X"
curl -L -o fleet.zip "https://github.com/coreos/fleet/releases/download/v$LATEST_RELEASE/fleet-v$LATEST_RELEASE-darwin-amd64.zip"
unzip -j -o "fleet.zip" "fleet-v$LATEST_RELEASE-darwin-amd64/fleetctl"
rm -f fleet.zip

# download docker client
cd ~/coreos-osx/coreos-vagrant
DOCKER_VERSION=$(vagrant ssh -c 'docker version' | grep 'Server version:' | cut -d " " -f 3- | tr -d '\r')

CHECK_DOCKER_RC=$(echo $DOCKER_VERSION | grep rc)
if [ -n "$CHECK_DOCKER_RC" ]
then
    # docker RC release
    if [ -n "$(curl -s --head https://test.docker.com/builds/Darwin/x86_64/docker-$DOCKER_VERSION | head -n 1 | grep "HTTP/1.[01] [23].." | grep 200)" ]
    then
        # we check if RC is still available
        echo "Downloading docker $DOCKER_VERSION client for OS X"
        curl -o ~/coreos-osx/bin/docker https://test.docker.com/builds/Darwin/x86_64/docker-$DOCKER_VERSION
    else
        # RC is not available anymore, so we download stable release
        DOCKER_VERSION_STABLE=$(echo $DOCKER_VERSION | cut -d"-" -f1)
        echo "Downloading docker $DOCKER_VERSION_STABLE client for OS X"
        curl -o ~/coreos-osx/bin/docker https://get.docker.com/builds/Darwin/x86_64/docker-$DOCKER_VERSION_STABLE
    fi
else
    # docker stable release
    echo "Downloading docker $DOCKER_VERSION client for OS X"
    curl -o ~/coreos-osx/bin/docker https://get.docker.com/builds/Darwin/x86_64/docker-$DOCKER_VERSION
fi
# Make it executable
chmod +x ~/coreos-osx/bin/docker
#

## Load docker images if there any
# Set the environment variable for the docker daemon
export DOCKER_HOST=tcp://127.0.0.1:2375

# path to the bin folder where we store our binary files
export PATH=${HOME}/coreos-osx/bin:$PATH

function pause(){
read -p "$*"
}

echo " "
echo "# It can upload your docker images to CoreOS VM # "
echo "If you want copy your docker images in *.tar format to ~/coreos-osx/docker_images folder !!!"
pause 'Press [Enter] key to continue...'

cd ~/coreos-osx/docker_images

if [ "$(ls | grep -o -m 1 tar)" = "tar" ]
then
    for file in *.tar
    do
        echo "Loading docker image: $file"
        docker load < $file
    done
    echo "Done with docker images !!!"
else
    echo "Nothing to upload !!!"
fi
echo " "
##

# set fleetctl endpoint and install fleet units
export FLEETCTL_ENDPOINT=http://172.19.8.99:4001
export FLEETCTL_DRIVER=etcd
export FLEETCTL_STRICT_HOST_KEY_CHECKING=false
echo "fleetctl list-machines:"
fleetctl list-machines
echo " "
# install fleet units
echo "Installing fleet units from '~/coreos-osx/fleet' folder"
cd ~/coreos-osx/fleet
~/coreos-osx/bin/fleetctl submit *.service
~/coreos-osx/bin/fleetctl start *.service
echo "Finished installing fleet units:"
fleetctl list-units
echo " "

#
echo "Installation has finished, CoreOS VM is up and running !!!"
echo "Enjoy CoreOS-Vagrant VM on your Mac !!!"
echo ""
echo "Run from menu 'OS Shell' to open a terninal window with docker, fleetctl, etcdctl and rkt pre-set !!!"
echo ""
pause 'Press [Enter] key to continue...'

