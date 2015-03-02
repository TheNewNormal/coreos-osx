#!/bin/bash

#  update.command
#  CoreOS GUI for OS X
#
#  Created by Rimantas on 01/04/2014.
#  Copyright (c) 2014 Rimantas Mocevicius. All rights reserved.

function pause(){
read -p "$*"
}

# get App's Resources folder
res_folder=$(cat ~/coreos-osx/.env/resouces_path)

# copy gsed to ~/coreos-osx/bin
cp -f "${res_folder}"/gsed ~/coreos-osx/bin
chmod 755 ~/coreos-osx/bin/gsed
# copy rkt to ~/coreos-osx/bin
cp -f "${res_folder}"/rkt ~/coreos-osx/bin
chmod 755 ~/coreos-osx/bin/rkt
# copy fleet units
###cp -f "${res_folder}"/*.service ~/coreos-osx/fleet

#
cd ~/coreos-osx/coreos-vagrant
vagrant box update
vagrant up

# download latest coreos-vagrant
rm -rf ~/coreos-osx/github
git clone https://github.com/coreos/coreos-vagrant/ ~/coreos-osx/github
echo "Downloads from github/coreos-vagrant are stored in ~/coreos-osx/github folder"
echo " "

# download latest Rocket on VM
ROCKET_RELEASE=$(curl 'https://api.github.com/repos/coreos/rocket/releases' 2>/dev/null|grep -o -m 1 -e "\"tag_name\":[[:space:]]*\"[a-z0-9.]*\""|head -1|cut -d: -f2|tr -d ' “' | cut -d '"' -f 2 )
echo "Downloading Rocket $ROCKET_RELEASE"

vagrant ssh -c 'sudo mkdir -p /opt/bin && sudo chmod -R 777 /opt/bin && cd /home/core && \
curl -L -o rocket.tar.gz "https://github.com/coreos/rocket/releases/download/'$ROCKET_RELEASE'/rocket-'$ROCKET_RELEASE'.tar.gz" && \
tar xzvf rocket.tar.gz && cp -f rocket-'$ROCKET_RELEASE'/* /opt/bin && sudo chmod 777 /opt/bin/rkt && /opt/bin/rkt version && \
rm -fr rocket-'$ROCKET_RELEASE' && rm -f rocket.tar.gz'
echo " "

# download latest versions of etcdctl and fleetctl
cd ~/coreos-osx/coreos-vagrant
LATEST_RELEASE=$(vagrant ssh -c "etcdctl --version" | cut -d " " -f 3- | tr -d '\r' )
cd ~/coreos-osx/bin
echo "Downloading etcdctl $LATEST_RELEASE for OS X"
curl -L -o etcd.zip "https://github.com/coreos/etcd/releases/download/v$LATEST_RELEASE/etcd-v$LATEST_RELEASE-darwin-amd64.zip"
unzip -j -o "etcd.zip" "etcd-v$LATEST_RELEASE-darwin-amd64/etcdctl"
rm -f etcd.zip
echo "etcdctl was copied to ~/coreos-osx/bin "
#
cd ~/coreos-osx/coreos-vagrant
LATEST_RELEASE=$(vagrant ssh -c 'fleetctl version' | cut -d " " -f 3- | tr -d '\r')
cd ~/coreos-osx/bin
echo "Downloading fleetctl v$LATEST_RELEASE for OS X"
curl -L -o fleet.zip "https://github.com/coreos/fleet/releases/download/v$LATEST_RELEASE/fleet-v$LATEST_RELEASE-darwin-amd64.zip"
unzip -j -o "fleet.zip" "fleet-v$LATEST_RELEASE-darwin-amd64/fleetctl"
rm -f fleet.zip
echo "fleetctl was copied to ~/coreos-osx/bin "
# download docker file
cd ~/coreos-osx/coreos-vagrant
LATEST_RELEASE=$(vagrant ssh -c 'docker version' | grep 'Server version:' | cut -d " " -f 3- | tr -d '\r')
echo "Downloading docker v$LATEST_RELEASE client for OS X"
curl -o ~/coreos-osx/bin/docker http://get.docker.io/builds/Darwin/x86_64/docker-$LATEST_RELEASE
# Make it executable
chmod +x ~/coreos-osx/bin/docker
echo "docker was copied to ~/coreos-osx/bin "
#

#
###echo " "
# set fleetctl tunnel
###export FLEETCTL_ENDPOINT=http://172.19.8.99:4001
###export FLEETCTL_STRICT_HOST_KEY_CHECKING=false

###cd ~/coreos-k8s-cluster/fleet

#
###  echo "Reinstalling fleet-ui.service "
###  ~/coreos-osx/bin/fleetctl destroy fleet-ui.service
###  ~/coreos-osx/bin/fleetctl submit fleet-ui.service
###  ~/coreos-osx/bin/fleetctl start fleet-ui.service
#
###  echo "Reinstalling dockerui.service "
###  ~/coreos-osx/bin/fleetctl destroy dockerui.service
###  ~/coreos-osx/bin/fleetctl submit dockerui.service
###  ~/coreos-osx/bin/fleetctl start dockerui.service
#

echo " "
echo "Update has finished !!!"
pause 'Press [Enter] key to continue...'
