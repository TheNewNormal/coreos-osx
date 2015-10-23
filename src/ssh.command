#!/bin/bash

#  ssh.command
# run commands on VM via ssh
#
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${DIR}"/functions.sh

# get App's Resources folder
res_folder=$(cat ~/coreos-osx/.env/resouces_path)

# get VM IP
#vm_ip=$( ~/coreos-osx/mac2ip.sh $(cat ~/coreos-osx/.env/mac_address))
vm_ip=$(cat ~/coreos-osx/.env/ip_address)

# pass some arguments via $1 $2 ...
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no core@$vm_ip $1 $2 $3 $4 $5 $6 $7 $8 $9 ${10} ${11} ${12}
