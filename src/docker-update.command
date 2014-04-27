#!/bin/bash

#  docker-update.command
#  CoreOS GUI for OS X
#
#  Created by Rimantas on 01/04/2014.
#  Copyright (c) 2014 Rimantas Mocevicius. All rights reserved.

function pause(){
read -p "$*"
}

# download latest version docker file
echo "Downloading docker client for OS X"
curl -o ~/coreos-osx/bin/docker http://get.docker.io/builds/Darwin/x86_64/docker-latest
# Make it executable
chmod +x ~/coreos-osx/bin/docker

~/coreos-osx/bin/docker version

pause 'Press [Enter] key to continue...'
