#!/bin/bash

# Upload docker images from files to CoreOS VM

# Set the environment variable for the docker daemon
export DOCKER_HOST=tcp://127.0.0.1:2375

# path to the bin folder where we store our binary files
export PATH=${HOME}/coreos-osx/bin:$PAT,H

function pause(){
read -p "$*"
}

echo " "
echo "# It will upload docker images to CoreOS VM # "
echo "Copy your docker images in *.tar format to ~/coreos-osx/docker_images folder !!!"
pause 'Press [Enter] key to continue...'

cd ~/coreos-osx/docker_images

for file in *.tar
do
    echo "Loading docker image: $file"
    docker load < $file
done

echo "Done !!!"
echo " "
pause 'Press [Enter] key to continue...'
