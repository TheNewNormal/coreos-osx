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
export PATH=${HOME}/coreos-osx/bin:$PATH

# set fleetctl endpoint
export FLEETCTL_ENDPOINT=http://172.17.8.99:4001
echo "fleetctl list-machines:"
fleetctl list-machines
echo ""
# 
echo "fleet list-units:"
fleetctl list-units
#
echo ""
echo "CoreOS VM was reloaded !!!"
echo ""
pause 'Press [Enter] key to continue...'
