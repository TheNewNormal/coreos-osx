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

# copy rkt to ~/coreos-osx/bin
cp -f "${res_folder}"/rkt ~/coreos-osx/bin

# copy docker-exec to ~/coreos-osx/bin
cp -f "${res_folder}"/docker-exec ~/coreos-osx/bin
#
chmod 755 ~/coreos-osx/bin/*

# copy fleet units
cp -f "${res_folder}"/*.service ~/coreos-osx/fleet

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
echo " "
# set fleetctl tunnel
export FLEETCTL_ENDPOINT=http://172.19.8.99:4001
export FLEETCTL_STRICT_HOST_KEY_CHECKING=false

cd ~/coreos-osx/fleet

#
  echo "Reinstalling fleet-ui.service "
  ~/coreos-osx/bin/fleetctl destroy fleet-ui.service
  ~/coreos-osx/bin/fleetctl start fleet-ui.service
#
  echo "Reinstalling dockerui.service "
  ~/coreos-osx/bin/fleetctl destroy dockerui.service
  ~/coreos-osx/bin/fleetctl start dockerui.service
#

echo " "
echo "Update has finished !!!"
pause 'Press [Enter] key to continue...'

