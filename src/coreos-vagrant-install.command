#!/bin/bash
#set -e

#  coreos-vagrant-install.command
#  CoreOS GUI for OS X
#
#  Created by Rimantas on 01/04/2014.
#  Copyright (c) 2014 Rimantas Mocevicius. All rights reserved.

# create symbolic link for vagrant to work on OS X 10.11
ln -s /opt/vagrant/bin/vagrant /usr/local/bin/vagrant >/dev/null 2>&1

    # create in "coreos-osx" all required folders and files at user's home folder where all the data will be stored
    mkdir ~/coreos-osx/coreos-vagrant
    mkdir ~/coreos-osx/tmp
    mkdir ~/coreos-osx/bin
    mkdir ~/coreos-osx/share
    chmod -R 777 ~/coreos-osx/share
    mkdir ~/coreos-osx/fleet
    mkdir ~/coreos-osx/my_fleet
    mkdir ~/coreos-osx/docker_images
    ###mkdir ~/coreos-osx/rkt_images

    # cd to App's Resources folder
    cd "$1"

    # copy fleet units
    cp -f "$1"/fleet/*.service ~/coreos-osx/fleet/

    # copy files to ~/coreos-osx/bin
    cp -f "$1"/bin/* ~/coreos-osx/bin
    #
    chmod 755 ~/coreos-osx/bin/*

    # copy vagrant files
    cp -f "$1"/Vagrant/* ~/coreos-osx/coreos-vagrant

    # copy temporal files for first-init.command script to be used at later time
    # copy sudoers file
    cp "$1"/files/sudoers ~/coreos-osx/tmp

    # initial init
    open -a iTerm.app "$1"/first-init.command
