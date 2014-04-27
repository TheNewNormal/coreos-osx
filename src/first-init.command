#!/bin/bash

#  first-init.command
#  CoreOS GUI for OS X
#
#  Created by Rimantas on 01/04/2014.
#  Copyright (c) 2014 Rimantas Mocevicius. All rights reserved.

function pause(){
read -p "$*"
}

# download latest docker OS X client
echo "Downloading docker client for OS X"
curl -o ~/coreos-osx/bin/docker http://get.docker.io/builds/Darwin/x86_64/docker-latest
# Make it executable
chmod +x ~/coreos-osx/bin/docker

# first up to initialise VM
echo "Setting up Vagrant VM for CoreOS"
cd ~/coreos-osx/coreos-vagrant
vagrant up

echo "Installation is finished, your CoreOS-Vagrant VM is up and running, enjoy !!!"
pause 'Press [Enter] key to continue...'


