#!/bin/bash

# upload_docker_images.command
#

#
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${DIR}"/functions.sh

# get App's Resources folder
res_folder=$(cat ~/coreos-osx/.env/resouces_path)

# path to the bin folder where we store our binary files
export PATH=${HOME}/coreos-osx/bin:$PATH

# get VM's IP
vm_ip=$(~/bin/corectl q -i core-01)

# Set the environment variables
# docker daemon
export DOCKER_HOST=tcp://$vm_ip:2375

## Load docker images if there any
echo " "
echo "# You can upload your docker images to CoreOS VM # "
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
        echo "Done with docker images !!!"
    else
        echo "Nothing to upload !!!"
    fi
echo " "
#

pause 'Press [Enter] key to continue...'

