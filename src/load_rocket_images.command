#!/bin/bash

# Upload docker images from files

function pause(){
read -p "$*"
}

echo "# It will upload docker images to CoreOS VM # "
echo "Copy your docker images in *.tar format to ~/coreos-osx/docker_images folder !!!"
pause 'Press [Enter] key to continue...'

cd ~/coreos-osx/docker_images

for file in *.tar
do
    echo "Loading docker image $file"
    docker load < $file
done

echo ""
echo "Upload has finished if there where any images they got uploaded !!!"
pause 'Press [Enter] key to continue...'
