#!/bin/bash

#  os_shell.command
#  CoreOS Vagrant GUI for OS X
#
#  Created by Rimantas on 01/12/2014.
#  Copyright (c) 2014 Rimantas Mocevicius. All rights reserved.

# Set the environment variable for the docker daemon
export DOCKER_HOST=tcp://127.0.0.1:2375

# path to the bin folder where we store our binary files
export PATH=${HOME}/coreos-osx/bin:$PATH

# set etcd endpoint
export ETCDCTL_PEERS=http://172.19.8.99:4001
echo "etcdctl ls /:"
etcdctl --no-sync ls /
echo ""

# set fleetctl endpoint
export FLEETCTL_ENDPOINT=http://172.19.8.99:4001
export FLEETCTL_DRIVER=etcd
export FLEETCTL_STRICT_HOST_KEY_CHECKING=false
echo "fleetctl list-machines:"
fleetctl list-machines
echo " "
echo "fleetctl list-units:"
fleetctl list-units
echo " "

cd ~/coreos-osx

# open bash shell
/bin/bash
