#!/bin/bash

#  halt.command
# stop VM via ssh

# get App's Resources folder
res_folder=$(cat ~/coreos-osx/.env/resouces_path)

# get VM IP
#vm_ip=$( ~/coreos-osx/mac2ip.sh $(cat ~/coreos-osx/.env/mac_address))
vm_ip=$(cat ~/coreos-osx/.env/ip_address)

# send halt to VM
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o ConnectTimeout=5 core@$vm_ip sudo halt

# just in case run
clean_up_after_vm

