#!/bin/bash

#  vagrant_up.command
#  CoreOS GUI for OS X
#
#  Created by Rimantas on 01/04/2014.
#  Copyright (c) 2014 Rimantas Mocevicius. All rights reserved.

function pause(){
read -p "$*"
}

cd ~/coreos-osx/coreos-vagrant
vagrant reload

# path to the bin folder where we store our binary files
export PATH=$PATH:${HOME}/coreos-osx/bin

# set fleetctl tunnel
# Add vagrant ssh key to ssh-agent
#vagrant ssh-config | sed -n "s/IdentityFile//gp" | xargs ssh-add
ssh-add ~/.vagrant.d/insecure_private_key

export FLEETCTL_TUNNEL="$(vagrant ssh-config | sed -n "s/[ ]*HostName[ ]*//gp"):$(vagrant ssh-config | sed -n "s/[ ]*Port[ ]*//gp")"
export FLEETCTL_STRICT_HOST_KEY_CHECKING=false
echo "fleetctl list-machines :"
fleetctl list-machines
echo ""
echo "fleetctl list-units :"
fleetctl list-units
#
echo ""
echo "CoreOS VM was reloaded !!!"
echo ""
pause 'Press [Enter] key to continue...'
