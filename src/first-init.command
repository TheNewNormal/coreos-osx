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
###ssh-add ~/.vagrant.d/insecure_private_key
vagrant ssh-config | sed -n "s/IdentityFile//gp" | xargs ssh-add

# first up to initialise VM
echo "Setting up Vagrant VM for CoreOS on OS X"
cd ~/coreos-osx/coreos-vagrant
vagrant box update
vagrant up

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

# download docker file
cd ~/coreos-osx/coreos-vagrant
LATEST_RELEASE=$(vagrant ssh -c 'docker version' | grep 'Server version:' | cut -d " " -f 3- | tr -d '\r')
echo "Downloading docker v$LATEST_RELEASE client for OS X"
curl -o ~/coreos-osx/bin/docker http://get.docker.io/builds/Darwin/x86_64/docker-$LATEST_RELEASE
# Make it executable
chmod +x ~/coreos-osx/bin/docker
#


echo "Installation has finished, enjoy CoreOS-Vagrant VM on your Mac!!!"
pause 'Press [Enter] key to continue...'

