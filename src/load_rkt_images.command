#!/bin/bash

# Upload rkt images from files

function pause(){
read -p "$*"
}

echo "# It will upload rkt images to CoreOS VM # "
echo "Copy your rkt images (*.aci) to ~/coreos-osx/rkt_images folder !!!"
pause 'Press [Enter] key to continue...'

cd ~/coreos-osx/rkt_images

for file in *.aci
do
    echo "Loading rkt image $file"

done

echo ""
echo "Upload has finished if there where any images they got uploaded !!!"
pause 'Press [Enter] key to continue...'
