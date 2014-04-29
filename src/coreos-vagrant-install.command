#!/bin/bash -x

#  coreos-vagrant-install.command
#  CoreOS GUI for OS X
#
#  Created by Rimantas on 01/04/2014.
#  Copyright (c) 2014 Rimantas Mocevicius. All rights reserved.

if [ ! -d ~/coreos-osx/ ]; then

    # create "coreos-osx" folder at user's home folder where the all files will be stored
    mkdir ~/coreos-osx

    # create "bin" folder
    mkdir ~/coreos-osx/bin

    # create the "share" folder share
    mkdir ~/coreos-osx/share

    # download latest coreos-vagrant
    git clone https://github.com/coreos/coreos-vagrant/ ~/coreos-osx/coreos-vagrant

    cd ~/Desktop/CoreOS\ GUI.app/Contents/Resources

    # copy updated Vagrantfile till the sed insert will be implemented
    cp Vagrantfile ~/coreos-osx/coreos-vagrant/

    # copy user-data file
    cp user-data ~/coreos-osx/coreos-vagrant/user-data

    # Make changes to Vagrant file
    #sed -i "" 's/172.17.8.#{i+100}/172.17.8.99/g' ~/coreos-osx/coreos-vagrant/Vagrantfile

    # copy vagrant_ssh.command
    cp vagrant_ssh.command ~/coreos-osx/bin/

    # copy vagrant_up.command
    cp vagrant_up.command ~/coreos-osx/bin/

    # copy install_vagrant_sudoers.command
    cp install_vagrant_sudoers.command ~/coreos-osx/bin/

    # initial init
    cp first-init.command ~/coreos-osx/bin/
    open -a iTerm.app ~/coreos-osx/bin/first-init.command

fi
