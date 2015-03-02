#!/bin/bash
set -e

#  coreos-vagrant-install.command
#  CoreOS GUI for OS X
#
#  Created by Rimantas on 01/04/2014.
#  Copyright (c) 2014 Rimantas Mocevicius. All rights reserved.

    # create "coreos-osx" and other required folders and files at user's home folder where all the data will be stored
    mkdir ~/coreos-osx
    mkdir ~/coreos-osx/.env
    mkdir ~/coreos-osx/coreos-vagrant
    mkdir ~/coreos-osx/tmp
    mkdir ~/coreos-osx/bin
    mkdir ~/coreos-osx/share
    chmod -R 777 ~/coreos-osx/share
    mkdir ~/coreos-osx/fleet
    mkdir ~/coreos-osx/my_fleet
    mkdir ~/coreos-osx/docker_images
    mkdir ~/coreos-osx/rocket_images

    # cd to App's Resources folder
    cd "$1"

    # copy fleet units
    cp "$1"/*.service ~/coreos-osx/fleet/

    # copy gsed to ~/coreos-osx/bin
    cp "$1"/gsed ~/coreos-osx/bin

   # copy rkt to ~/coreos-osx/bin
    cp "$1"/rkt ~/coreos-osx/bin

    # copy temporal files for first-init.command script use later one
    # shared folder
    cp "$1"/Vagrantfile ~/coreos-osx/tmp/Vagrantfile
    # copy sudoers file
    cp "$1"/sudoers ~/coreos-osx/tmp
    # copy user-data file
    cp "$1"/user-data ~/coreos-osx/tmp

    # initial init
    open -a iTerm.app "$1"/first-init.command
