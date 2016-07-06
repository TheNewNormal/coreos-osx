#!/bin/bash

#  Reload VM
#
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${DIR}"/functions.sh

# get App's Resources folder
res_folder=$(cat ~/coreos-osx/.env/resouces_path)

# path to the bin folder where we store our binary files
export PATH=${HOME}/coreos-osx/bin:$PATH

### Stop VM
echo " "
echo "Stopping VM ..."

# send halt to VM
/usr/local/sbin/corectl halt core-01

#
sleep 3

# check corectld server
check_corectld_server

# Start VM
cd ~/coreos-osx
echo " "
echo "Starting VM ..."
#
/usr/local/sbin/corectl load settings/core-01.toml 2>&1 | tee ~/coreos-osx/logs/vm_reload.log
CHECK_VM_STATUS=$(cat ~/coreos-osx/logs/vm_reload.log | grep "started")
#
if [[ "$CHECK_VM_STATUS" == "" ]]; then
    echo " "
    echo "VM have not booted, please check '~/coreos-osx/logs/vm_reload.log' and report the problem !!! "
    echo " "
    pause 'Press [Enter] key to continue...'
    exit 0
else
    echo "VM successfully started !!!" >> ~/coreos-osx/logs/vm_reload.log
fi

# check if /Users/homefolder is mounted, if not mount it
/usr/local/sbin/corectl ssh core-01 'source /etc/environment; if df -h | grep ${HOMEDIR}; then echo 0; else sudo systemctl restart ${HOMEDIR}; fi' > /dev/null 2>&1
echo " "

# get VM's IP
vm_ip=$(/usr/local/sbin/corectl q -i core-01)
# save VM's IP
/usr/local/sbin/corectl q -i core-01 | tr -d "\n" > ~/coreos-osx/.env/ip_address
#

echo "CoreOS VM was reloaded !!!"
echo ""
pause 'Press [Enter] key to continue...'
