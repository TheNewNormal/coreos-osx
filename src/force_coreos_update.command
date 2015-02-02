#!/bin/bash

#  force_coreos_update.command
#  CoreOS GUI for OS X
#
#  Created by Rimantas on 01/04/2014.
#  Copyright (c) 2014 Rimantas Mocevicius. All rights reserved.

function pause(){
read -p "$*"
}

cd ~/coreos-osx/coreos-vagrant
vagrant up
vagrant ssh -c "sudo update_engine_client -update"

echo " "
echo "Update has finished !!!"
pause 'Press [Enter] key to continue...'
