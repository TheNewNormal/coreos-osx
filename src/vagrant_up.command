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
vagrant ssh-config core-01 | sed -n "s/IdentityFile//gp" | xargs ssh-add
###ssh-add ~/.vagrant.d/insecure_private_key

# Set the environment variable for the docker daemon
export DOCKER_HOST=tcp://127.0.0.1:2375
###export DOCKER_HOST="tcp://$(vagrant ssh-config | grep 'HostName' | cut -d " " -f 4- | tr -d '\r'):2375"

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

# install rocket
if [ "$machine_status" = "not created" ]
then
    cd ~/coreos-osx/coreos-vagrant
    # download and install latest Rocket on VM
    ROCKET_RELEASE=$(curl 'https://api.github.com/repos/coreos/rocket/releases' 2>/dev/null|grep -o -m 1 -e "\"tag_name\":[[:space:]]*\"[a-z0-9.]*\""|head -1|cut -d: -f2|tr -d ' “' | cut -d '"' -f 2 )
    echo "Downloading Rocket $ROCKET_RELEASE"
    vagrant ssh -c 'sudo mkdir -p /opt/bin && sudo chmod -R 777 /opt/bin && cd /home/core && \
    curl -L -o rocket.tar.gz "https://github.com/coreos/rocket/releases/download/'$ROCKET_RELEASE'/rocket-'$ROCKET_RELEASE'.tar.gz" && \
    tar xzvf rocket.tar.gz && cp -f rocket-'$ROCKET_RELEASE'/* /opt/bin && sudo chmod 777 /opt/bin/rkt && /opt/bin/rkt version && \
    rm -fr rocket-'$ROCKET_RELEASE' && rm -f rocket.tar.gz'
    echo " "
fi


# set etcd endpoint
export ETCDCTL_PEERS=http://172.19.8.99:4001
echo "etcdctl ls /:"
etcdctl --no-sync ls /
echo " "

# set fleetctl endpoint
export FLEETCTL_ENDPOINT=http://172.19.8.99:4001
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
