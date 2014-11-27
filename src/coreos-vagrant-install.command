#!/bin/bash

#  coreos-vagrant-install.command
#  CoreOS GUI for OS X
#
#  Created by Rimantas on 01/04/2014.
#  Copyright (c) 2014 Rimantas Mocevicius. All rights reserved.

    # create "coreos-osx" and other required folders and files at user's home folder where all the data will be stored
    mkdir ~/coreos-osx
    mkdir ~/coreos-osx/coreos-vagrant
    mkdir ~/coreos-osx/tmp
    mkdir ~/coreos-osx/bin
    mkdir ~/coreos-osx/share
    mkdir ~/coreos-osx/fleet

    # download latest coreos-vagrant
    rm -rf ~/coreos-osx/github
    git clone https://github.com/coreos/coreos-vagrant/ ~/coreos-osx/github

    # cd to App's Resources folder
    cd "$1"

### Vagrantfile ###
    cp ~/coreos-osx/github/Vagrantfile ~/coreos-osx/coreos-vagrant/Vagrantfile
    # change IP to static
    sed -i "" 's/172.17.8.#{i+100}/172.17.8.99/g' ~/coreos-osx/coreos-vagrant/Vagrantfile

    # Insert shared folder
    cp "$1"/Vagrantfile ~/coreos-osx/tmp/Vagrantfile
    "$1"/gsed -i "/#config.vm.synced_folder/r $HOME/coreos-osx/tmp/Vagrantfile" ~/coreos-osx/coreos-vagrant/Vagrantfile
    rm -f ~/coreos-osx/tmp/Vagrantfile

### Vagrantfile ###

### user-data file ###
    cat ~/coreos-osx/github/user-data.sample user-data > ~/coreos-osx/coreos-vagrant/user-data

    # config.rb file
    cp ~/coreos-osx/github/config.rb.sample ~/coreos-osx/coreos-vagrant/config.rb

    # Set release channel
    LOOP=1
    while [ $LOOP -gt 0 ]
    do
        VALID_MAIN=0
        echo " "
        echo " CoreOS Release Channel:"
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
    # Set release channel


    # expose docker port
    sed -i "" 's/#$expose_docker_tcp/$expose_docker_tcp/' ~/coreos-osx/coreos-vagrant/config.rb
### user-data file ###

    # initial init
    open -a iTerm.app "$1"/first-init.command
