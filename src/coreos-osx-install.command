#!/bin/bash

#  coreos-osx-install.command
#

    # create in "coreos-osx" all required folders and files at user's home folder where all the data will be stored
    mkdir ~/coreos-osx
    mkdir ~/coreos-osx/tmp
    mkdir ~/coreos-osx/logs
    mkdir ~/coreos-osx/bin
    mkdir ~/coreos-osx/cloud-init
    mkdir ~/coreos-osx/settings
    mkdir ~/coreos-osx/fleet
    mkdir ~/coreos-osx/my_fleet
    mkdir ~/coreos-osx/registry
    mkdir ~/coreos-osx/docker_images
    ###mkdir ~/coreos-osx/rkt_images

    # cd to App's Resources folder
    cd "$1"

    # copy files to ~/coreos-osx/bin
    cp -f "$1"/bin/* ~/coreos-osx/bin
    chmod 755 ~/coreos-osx/bin/*

    # copy user-data
    cp -f "$1"/cloud-init/* ~/coreos-osx/cloud-init

    # copy settings
    cp -f "$1"/settings/* ~/coreos-osx/settings

    # copy fleet units
    cp -f "$1"/fleet/* ~/coreos-osx/fleet

    # copy docker registry config
    cp -f "$1"/registry/config.yml ~/coreos-osx/registry

    # check if iTerm.app exists
    App="/Applications/iTerm.app"
    if [ ! -d "$App" ]
    then
        unzip "$1"/files/iTerm2.zip -d /Applications/
    fi

    # initial init
    open -a iTerm.app "$1"/first-init.command
