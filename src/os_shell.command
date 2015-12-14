#!/bin/bash

#  Pre-set OS shell
#

# get App's Resources folder
res_folder=$(cat ~/coreos-osx/.env/resouces_path)

# get VM's IP
#vm_ip=$(corectl ps -j | jq ".[] | select(.Name==\"core-01\") | .PublicIP" | sed -e 's/"\(.*\)"/\1/')
vm_ip=$(<~/coreos-osx/.env/ip_address)

# path to the bin folder where we store our binary files
export PATH=${HOME}/coreos-osx/bin:$PATH

# Set the environment variable for the docker daemon
export DOCKER_HOST=tcp://$vm_ip:2375

# set etcd endpoint
export ETCDCTL_PEERS=http://$vm_ip:2379
echo " "
echo "etcdctl ls /:"
etcdctl --no-sync ls /
echo " "

# set fleetctl endpoint
export FLEETCTL_TUNNEL=
export FLEETCTL_ENDPOINT=http://$vm_ip:2379
export FLEETCTL_DRIVER=etcd
export FLEETCTL_STRICT_HOST_KEY_CHECKING=false
echo "fleetctl list-machines:"
fleetctl list-machines
echo " "
echo "fleetctl list-units:"
fleetctl list-units
echo " "

cd ~/coreos-osx

# open bash shell
/bin/bash
