#!/bin/bash

#  vagrant_up.command
#  CoreOS GUI for OS X
#
#  Created by Rimantas on 01/04/2014.
#  Copyright (c) 2014 Rimantas Mocevicius. All rights reserved.

cd ~/coreos-osx/coreos-vagrant

machine_status=$(vagrant status | grep -o -m 1 'not created')

vagrant up

# Add vagrant ssh key to ssh-agent
###vagrant ssh-config core-01 | sed -n "s/IdentityFile//gp" | xargs ssh-add
ssh-add ~/.vagrant.d/insecure_private_key >/dev/null 2>&1

# Set the environment variable for the docker daemon
export DOCKER_HOST=tcp://127.0.0.1:2375

# path to the bin folder where we store our binary files
export PATH=${HOME}/coreos-osx/bin:$PATH

if [ "$machine_status" = "not created" ]
then
    if [ "$(ls ~/coreos-osx/docker_images | grep -o -m 1 tar)" = "tar" ]
    then
        sleep 5
        echo "docker images will be uploaded from ~/coreos-osx/docker_images folder !!!"
        cd ~/coreos-osx/docker_images

        for file in *.tar
        do
            echo "Loading docker image: $file"
            docker load < $file
        done
        echo "Done !!!"
    fi
fi


# set etcd endpoint
export ETCDCTL_PEERS=http://172.19.8.99:2379
echo "etcdctl ls /:"
etcdctl --no-sync ls /
echo " "

# set fleetctl endpoint
export FLEETCTL_ENDPOINT=http://172.19.8.99:2379
export FLEETCTL_DRIVER=etcd
export FLEETCTL_STRICT_HOST_KEY_CHECKING=false
echo "fleetctl list-machines:"
fleetctl list-machines
echo ""

# list fleet units
cd ~/coreos-osx/fleet
echo "Start all fleet units in ~/coreos-osx/fleet:"
fleetctl start *.service
echo "fleetctl list-units:"
fleetctl list-units
echo " "

# deploy fleet units from ~/coreos-osx/my_fleet
if [ "$machine_status" = "not created" ]
then
    if [ "$(ls ~/coreos-osx/my_fleet | grep -o -m 1 service)" = "service" ]
    then
        cd ~/coreos-osx/my_fleet
        echo "Start all fleet units in ~/coreos-osx/my_fleet:"
        fleetctl start *.service
        echo "fleetctl list-units:"
        fleetctl list-units
        echo " "
    fi
fi

cd ~/coreos-osx

# open bash shell
/bin/bash
