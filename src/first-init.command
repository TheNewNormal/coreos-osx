#!/bin/bash

#  first-init.command
#  CoreOS GUI for OS X
#
#  Created by Rimantas on 01/04/2014.
#  Copyright (c) 2014 Rimantas Mocevicius. All rights reserved.

function pause(){
read -p "$*"
}

# Add vagrant ssh key to ssh-agent
ssh-add ~/.vagrant.d/insecure_private_key

# Add current user to sudoers
echo "Add current user to sudoers for the shared folder access from the VM"
sudo ~/coreos-osx/bin/install_vagrant_sudoers.command
sudo chmod +w /etc/exports

# donwload etcdctl and fleetctl
cd ~/coreos-osx/bin

echo "Download the lastest etcdctl for OS X"
LATEST_RELEASE=$(curl 'https://api.github.com/repos/coreos/etcd/releases' 2>/dev/null|grep -o -m 1 -e "\"tag_name\":[[:space:]]*\"[a-z0-9.]*\""|head -1|cut -d: -f2|tr -d ' "')
curl -L -o etcd.zip "https://github.com/coreos/etcd/releases/download/$LATEST_RELEASE/etcd-$LATEST_RELEASE-darwin-amd64.zip"
unzip -j -o "etcd.zip" "etcd-$LATEST_RELEASE-darwin-amd64/etcdctl"
rm -f etcd.zip
#
echo "Download the lastest fleetctl for OS X"
LATEST_RELEASE=$(curl 'https://api.github.com/repos/coreos/fleet/releases' 2>/dev/null|grep -o -m 1 -e "\"tag_name\":[[:space:]]*\"[a-z0-9.]*\""|head -1|cut -d: -f2|tr -d ' "')
curl -L -o fleet.zip "https://github.com/coreos/fleet/releases/download/$LATEST_RELEASE/fleet-$LATEST_RELEASE-darwin-amd64.zip"
unzip -j -o "fleet.zip" "fleet-$LATEST_RELEASE-darwin-amd64/fleetctl"
rm -f fleet.zip

# download latest docker OS X client
echo "Downloading docker client for OS X"
curl -o ~/coreos-osx/bin/docker http://get.docker.io/builds/Darwin/x86_64/docker-latest
# Make it executable
chmod +x ~/coreos-osx/bin/docker


# removing the old box file and vagrant will download the latest one on the next vagrant up
vagrant box remove coreos-alpha --provider virtualbox

# first up to initialise VM
echo "Setting up Vagrant VM for CoreOS"
cd ~/coreos-osx/coreos-vagrant
vagrant up

echo "Installation has finished, your CoreOS-Vagrant VM is up and running, enjoy !!!"
pause 'Press [Enter] key to continue...'

