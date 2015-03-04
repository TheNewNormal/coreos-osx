#!/bin/bash

# Upload docker images from files to CoreOS VM

cd ~/coreos-osx/coreos-vagrant

machine_status=$(vagrant status | grep -o -m 1 'running')

# Set the environment variable for the docker daemon
export DOCKER_HOST=tcp://127.0.0.1:2375

# path to the bin folder where we store our binary files
export PATH=${HOME}/coreos-osx/bin:$PAT,H

function pause(){
read -p "$*"
}

if [ "$machine_status" = "running" ]
then
    echo " "
    echo "# It will upload docker images to CoreOS VM # "
    echo "Copy your docker images in *.tar format to ~/coreos-osx/docker_images folder !!!"
    pause 'Press [Enter] key to continue...'

    cd ~/coreos-osx/docker_images

    if [ "$(ls | grep -o -m 1 tar)" = "tar" ]
    then

        for file in *.tar
        do
            echo "Loading docker image: $file"
            docker load < $file
        done
        echo "Done !!!"
    else
        echo "Nothing to upload !!!"
    fi
    echo " "
    pause 'Press [Enter] key to continue...'
else
    echo " "
    echo "VM is not running, cannot upload docker images !!!"
    pause 'Press [Enter] key to continue...'
fi
