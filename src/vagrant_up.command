#!/bin/bash

#  vagrant_up.command
#  CoreOS GUI for OS X
#
#  Created by Rimantas on 01/04/2014.
#  Copyright (c) 2014 Rimantas Mocevicius. All rights reserved.

cd ~/coreos-osx/coreos-vagrant
vagrant up

# Set the environment variable for the docker daemon
export DOCKER_HOST=tcp://127.0.0.1:2375
###export DOCKER_HOST="tcp://$(vagrant ssh-config | grep 'HostName' | cut -d " " -f 4- | tr -d '\r'):2375"

# path to the bin folder where we store our binary files
export PATH=$PATH:${HOME}/coreos-osx/bin

# set fleetctl tunnel
vagrant ssh-config | sed -n "s/IdentityFile//gp" | xargs ssh-add
export FLEETCTL_TUNNEL="$(vagrant ssh-config | sed -n "s/[ ]*HostName[ ]*//gp"):$(vagrant ssh-config | sed -n "s/[ ]*Port[ ]*//gp")"
export FLEETCTL_STRICT_HOST_KEY_CHECKING=false

#ssh-add ~/.vagrant.d/insecure_private_key

cd ~/coreos-osx/share

# open bash shell
/bin/bash
