#!/bin/bash

#  coreos-osx-install.command
#

    # create in "coreos-osx" all required folders and files at user's home folder where all the data will be stored
    mkdir -p ~/.coreos-xhyve/imgs
    mkdir ~/coreos-osx
    ln -s ~/.coreos-xhyve/imgs ~/coreos-osx/imgs
    mkdir ~/coreos-osx/tmp
    mkdir ~/coreos-osx/bin
    mkdir ~/coreos-osx/cloud-init
    mkdir ~/coreos-osx/fleet
    mkdir ~/coreos-osx/my_fleet
    mkdir ~/coreos-osx/registry
    mkdir ~/coreos-osx/docker_images
    ###mkdir ~/coreos-osx/rkt_images

    # cd to App's Resources folder
    cd "$1"

    # copy files to ~/coreos-osx/bin
    cp -f "$1"/files/* ~/coreos-osx/bin
    rm -f ~/coreos-osx/bin/iTerm2.zip

    # copy xhyve to bin folder
    cp -f "$1"/bin/xhyve ~/coreos-osx/bin
    chmod 755 ~/coreos-osx/bin/*

    # copy user-data
    cp -f "$1"/settings/user-data ~/coreos-osx/cloud-init
    cp -f "$1"/settings/user-data-format-root ~/coreos-osx/cloud-init

    # copy custom.conf
    cp -f "$1"/settings/custom.conf ~/coreos-osx

    # copy fleet units
    cp -R "$1"/fleet/ ~/coreos-osx/fleet
    #

    # copy registry files
    cp -f "$1"/registry/config.yml ~/coreos-osx/registry
    cp -f "$1"/bin/registry ~/coreos-osx/bin
    chmod 755 ~/coreos-osx/bin/registry

    # check if iTerm.app exists
    App="/Applications/iTerm.app"
    if [ ! -d "$App" ]
    then
        unzip "$1"/files/iTerm2.zip -d /Applications/
    fi

    # initial init
    open -a iTerm.app "$1"/first-init.command
