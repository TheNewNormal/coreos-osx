#!/bin/bash

#  update.command
#  CoreOS GUI for OS X
#
#  Created by Rimantas on 01/04/2014.
#  Copyright (c) 2014 Rimantas Mocevicius. All rights reserved.

function pause(){
read -p "$*"
}

# download latest versions of etcdctl and fleetctl
echo "Downloading the lastest etcdctl for OS X"
LATEST_RELEASE=$(curl 'https://api.github.com/repos/coreos/etcd/releases' 2>/dev/null|grep -o -m 1 -e "\"tag_name\":[[:space:]]*\"[a-z0-9.]*\""|head -1|cut -d: -f2|tr -d ' "')
curl -L -o etcd.zip "https://github.com/coreos/etcd/releases/download/$LATEST_RELEASE/etcd-$LATEST_RELEASE-darwin-amd64.zip"
unzip -j -o "etcd.zip" "etcd-$LATEST_RELEASE-darwin-amd64/etcdctl"
mv -f etcdctl ~/coreos-osx/bin/ && rm -f etcd.zip
#
echo "Downloading the lastest fleetctl for OS X"
LATEST_RELEASE=$(curl 'https://api.github.com/repos/coreos/fleet/releases' 2>/dev/null|grep -o -m 1 -e "\"tag_name\":[[:space:]]*\"[a-z0-9.]*\""|head -1|cut -d: -f2|tr -d ' "')
curl -L -o fleet.zip "https://github.com/coreos/fleet/releases/download/$LATEST_RELEASE/fleet-$LATEST_RELEASE-darwin-amd64.zip"
unzip -j -o "fleet.zip" "fleet-$LATEST_RELEASE-darwin-amd64/fleetctl"
mv -f fleetctl ~/coreos-osx/bin/ && rm -f fleet.zip

# download latest version docker file
echo "Downloading docker client for OS X"
curl -o ~/coreos-osx/bin/docker http://get.docker.io/builds/Darwin/x86_64/docker-latest
# Make it executable
chmod +x ~/coreos-osx/bin/docker

~/coreos-osx/bin/docker version

pause 'Press [Enter] key to continue...'
