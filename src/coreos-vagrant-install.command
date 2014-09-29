#!/bin/bash

#  coreos-vagrant-install.command
#  CoreOS GUI for OS X
#
#  Created by Rimantas on 01/04/2014.
#  Copyright (c) 2014 Rimantas Mocevicius. All rights reserved.

    # create "coreos-osx" folder at user's home folder where the all the data will be stored
    mkdir ~/coreos-osx
    mkdir ~/coreos-osx/coreos-vagrant
    mkdir ~/coreos-osx/tmp
    mkdir ~/coreos-osx/bin
    mkdir ~/coreos-osx/share

    # download latest coreos-vagrant
    rm -rf ~/coreos-osx/github
    git clone https://github.com/coreos/coreos-vagrant/ ~/coreos-osx/github

    # cd to App's Resources folder
    cd "$1"

    # Vagrantfile
    cp ~/coreos-osx/github/Vagrantfile ~/coreos-osx/coreos-vagrant/Vagrantfile
    # change IP to static
    sed -i "" 's/172.17.8.#{i+100}/172.17.8.99/g' ~/coreos-osx/coreos-vagrant/Vagrantfile
    # Insert port forwards
    cp "$1"/Vagrantfile ~/coreos-osx/tmp/Vagrantfile
    "$1"/gsed -i "/#config.vm.synced_folder/r $HOME/coreos-osx/tmp/Vagrantfile" ~/coreos-osx/coreos-vagrant/Vagrantfile
    rm -f ~/coreos-osx/tmp/Vagrantfile

    # user-data file
    # add DockerUI unit
    cat ~/coreos-osx/github/user-data.sample user-data > ~/coreos-osx/coreos-vagrant/user-data

    # config.rb file
    cp ~/coreos-osx/github/config.rb.sample ~/coreos-osx/coreos-vagrant/config.rb
    # set update channel
    sed -i "" 's/#$update_channel/$update_channel/' ~/coreos-osx/coreos-vagrant/config.rb
    ###sed -i "" "s/channel='alpha'/channel='beta'/" ~/coreos-osx/coreos-vagrant/config.rb
    # expose docker port
    sed -i "" 's/#$expose_docker_tcp/$expose_docker_tcp/' ~/coreos-osx/coreos-vagrant/config.rb

    # initial init
    open -a iTerm.app "$1"/first-init.command
