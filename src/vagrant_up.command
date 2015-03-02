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
export PATH=${HOME}/coreos-osx/bin:$PATH

# set etcd endpoint
export ETCDCTL_PEERS=http://172.19.8.99:4001
echo "etcd ls /:"
etcdctl --no-sync ls /
echo ""

# set fleetctl endpoint
export FLEETCTL_ENDPOINT=http://172.19.8.99:4001
export FLEETCTL_STRICT_HOST_KEY_CHECKING=false
echo "fleetctl list-machines:"
fleetctl list-machines
echo ""

# list fleet units
cd ~/coreos-osx/fleet
fleetctl start *.service
echo "fleet list-units:"
fleetctl list-units
echo " "

cd ~/coreos-osx

# open bash shell
/bin/bash
