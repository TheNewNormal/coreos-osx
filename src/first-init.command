#!/bin/bash

#  first-init.command
#  CoreOS GUI for OS X
#
#  Created by Rimantas on 01/04/2014.
#  Copyright (c) 2014 Rimantas Mocevicius. All rights reserved.

# getting files from github and setting them up
    echo ""
    echo "Downloading latest coreos-vagrant files from github: "
    rm -rf ~/coreos-osx/github
    git clone https://github.com/coreos/coreos-vagrant/ ~/coreos-osx/github
    echo "Done downloading from github !!!"
    echo ""

    # Vagrantfile
    cp ~/coreos-osx/github/Vagrantfile ~/coreos-osx/coreos-vagrant/Vagrantfile
    # change IP to static
    sed -i "" 's/172.17.8.#{i+100}/172.17.8.99/g' ~/coreos-osx/coreos-vagrant/Vagrantfile
    #

    # user-data file
    cat ~/coreos-osx/github/user-data.sample ~/coreos-osx/tmp/user-data > ~/coreos-osx/coreos-vagrant/user-data
    #

    # config.rb file
    cp ~/coreos-osx/github/config.rb.sample ~/coreos-osx/coreos-vagrant/config.rb
    # expose docker port
    sed -i "" 's/#$expose_docker_tcp/$expose_docker_tcp/' ~/coreos-osx/coreos-vagrant/config.rb
    #
#


### Insert shared folder to Vagrantfile
LOOP=1
while [ $LOOP -gt 0 ]
do
    VALID_MAIN=0
    echo "Do you want to enable NFS shared local folder '~/coreos-osx/share' to CoreOS VM '/home/coreos/share' one? [y/n]"
    echo "(if you already had it enabled just answer 'n' then.)"

    read RESPONSE
    XX=${RESPONSE:=Y}

    if [ $RESPONSE = y ]
    then
        VALID_MAIN=1
        # shared folder
        ~/coreos-osx/bin/gsed -i "/#config.vm.synced_folder/r $HOME/coreos-osx/tmp/Vagrantfile" ~/coreos-osx/coreos-vagrant/Vagrantfile

        # update /etc/sudoers file
        echo "(You will be asked for your OS X user password !!!)"
        CHECK_SUDOERS=$(sudo -s 'cat /etc/sudoers | grep "# Added by CoreOS GUI App"')
        if [ "$CHECK_SUDOERS" = "" ]
        then
            echo "Updating /etc/sudoers file"
            sudo -s 'cat ~/coreos-osx/tmp/sudoers >> /etc/sudoers'
        else
            echo "You already have in /etc/sudoers '# Added by CoreOS GUI App' lines !!!"
            echo "Please double check /etc/sudoers file for it and delete all lines starting # Added by CoreOS GUI App - start' !!!"
            echo "inclusevely lines with # Added by CoreOS GUI App too "
            echo "and add the entry shown below !!!"
            cat ~/coreos-osx/tmp/sudoers
        fi
        LOOP=0
    fi

    if [ $RESPONSE = n ]
    then
        VALID_MAIN=1
        LOOP=0
    fi

    if [ $VALID_MAIN != y ] || [ $VALID_MAIN != n ]
    then
        continue
    fi
done

# remove temporal files
rm -f ~/coreos-osx/tmp/*

### Insert shared folder to Vagrantfile

### Set release channel
LOOP=1
while [ $LOOP -gt 0 ]
do
    VALID_MAIN=0
    echo " "
    echo " Set CoreOS Release Channel:"
    echo " 1)  Alpha "
    echo " 2)  Beta "
    echo " 3)  Stable "
    echo " "
    echo "Select an option:"

    read RESPONSE
    XX=${RESPONSE:=Y}

    if [ $RESPONSE = 1 ]
    then
        VALID_MAIN=1
        sed -i "" 's/#$update_channel/$update_channel/' ~/coreos-osx/coreos-vagrant/config.rb
        sed -i "" "s/channel='stable'/channel='alpha'/" ~/coreos-osx/coreos-vagrant/config.rb
        sed -i "" "s/channel='beta'/channel='alpha'/" ~/coreos-osx/coreos-vagrant/config.rb
        LOOP=0
    fi

    if [ $RESPONSE = 2 ]
    then
        VALID_MAIN=1
        sed -i "" 's/#$update_channel/$update_channel/' ~/coreos-osx/coreos-vagrant/config.rb
        sed -i "" "s/channel='alpha'/channel='beta'/" ~/coreos-osx/coreos-vagrant/config.rb
        sed -i "" "s/channel='stable'/channel='beta'/" ~/coreos-osx/coreos-vagrant/config.rb
        LOOP=0
    fi

    if [ $RESPONSE = 3 ]
    then
        VALID_MAIN=1
        sed -i "" 's/#$update_channel/$update_channel/' ~/coreos-osx/coreos-vagrant/config.rb
        sed -i "" "s/channel='alpha'/channel='stable'/" ~/coreos-osx/coreos-vagrant/config.rb
        sed -i "" "s/channel='beta'/channel='stable'/" ~/coreos-osx/coreos-vagrant/config.rb
        LOOP=0
    fi

    if [ $VALID_MAIN != 1 ]
    then
        continue
    fi
done
### Set release channel


function pause(){
read -p "$*"
}

# first up to initialise VM
echo "Setting up Vagrant VM for CoreOS on OS X"
cd ~/coreos-osx/coreos-vagrant
vagrant box update
vagrant up

# Add vagrant ssh key to ssh-agent
###vagrant ssh-config core-01 | sed -n "s/IdentityFile//gp" | xargs ssh-add
ssh-add ~/.vagrant.d/insecure_private_key

# download etcdctl and fleetctl
#
cd ~/coreos-osx/coreos-vagrant
LATEST_RELEASE=$(vagrant ssh -c "etcdctl --version" | cut -d " " -f 3- | tr -d '\r' )
cd ~/coreos-osx/bin
echo "Downloading etcdctl $LATEST_RELEASE for OS X"
curl -L -o etcd.zip "https://github.com/coreos/etcd/releases/download/v$LATEST_RELEASE/etcd-v$LATEST_RELEASE-darwin-amd64.zip"
unzip -j -o "etcd.zip" "etcd-v$LATEST_RELEASE-darwin-amd64/etcdctl"
rm -f etcd.zip
#
cd ~/coreos-osx/coreos-vagrant
LATEST_RELEASE=$(vagrant ssh -c 'fleetctl version' | cut -d " " -f 3- | tr -d '\r')
cd ~/coreos-osx/bin
echo "Downloading fleetctl v$LATEST_RELEASE for OS X"
curl -L -o fleet.zip "https://github.com/coreos/fleet/releases/download/v$LATEST_RELEASE/fleet-v$LATEST_RELEASE-darwin-amd64.zip"
unzip -j -o "fleet.zip" "fleet-v$LATEST_RELEASE-darwin-amd64/fleetctl"
rm -f fleet.zip

# download docker client
cd ~/coreos-osx/coreos-vagrant
LATEST_RELEASE=$(vagrant ssh -c 'docker version' | grep 'Server version:' | cut -d " " -f 3- | tr -d '\r')
echo "Downloading docker v$LATEST_RELEASE client for OS X"
curl -o ~/coreos-osx/bin/docker http://get.docker.io/builds/Darwin/x86_64/docker-$LATEST_RELEASE
# Make it executable
chmod +x ~/coreos-osx/bin/docker
#

# set fleetctl tunnel and install fleet units
export FLEETCTL_TUNNEL="$(vagrant ssh-config | sed -n "s/[ ]*HostName[ ]*//gp"):$(vagrant ssh-config | sed -n "s/[ ]*Port[ ]*//gp")"
export FLEETCTL_STRICT_HOST_KEY_CHECKING=false
echo "fleetctl list-machines :"
fleetctl list-machines
echo ""
# install fleet units
echo "Installing fleet units from '~/coreos-osx/fleet' folder"
cd ~/coreos-osx/fleet
~/coreos-osx/bin/fleetctl --strict-host-key-checking=false submit *.service
~/coreos-osx/bin/fleetctl --strict-host-key-checking=false start *.service
echo "Finished installing fleet units"
fleetctl list-units
echo " "

#
echo "Installation has finished, CoreOS VM is up and running !!!"
echo "Enjoy CoreOS-Vagrant VM on your Mac !!!"
echo ""
echo "Run from menu 'Up & OS Shell' to open a terninal window with docker, fleetctl and etcdctl pre-set to cluster settings"
echo ""
pause 'Press [Enter] key to continue...'

