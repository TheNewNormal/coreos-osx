#!/bin/bash

#  change release channel
#

#
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${DIR}"/functions.sh

/usr/bin/sed -i "" 's/#shared-homedir/shared-homedir/' ~/coreos-osx/settings/core-01.toml

#
echo " "
echo "Shared NFS user home folder was enabled !!!"
echo "You need to reboot your VM if it is was running ..."
echo " "
pause 'Press [Enter] key to continue...'
