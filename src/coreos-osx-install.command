#!/bin/bash

#  coreos-osx-install.command
#
#
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${DIR}"/functions.sh

    # create in "coreos-osx" all required folders and files at user's home folder where all the data will be stored
    mkdir ~/coreos-osx
    mkdir ~/coreos-osx/tmp
    mkdir ~/coreos-osx/logs
    mkdir ~/coreos-osx/bin
    mkdir ~/coreos-osx/cloud-init
    mkdir ~/coreos-osx/settings
    mkdir ~/coreos-osx/docker_images
    mkdir ~/coreos-osx/rkt_images

    # cd to App's Resources folder
    cd "$1"

    # copy files to ~/coreos-osx/bin
    cp -f "$1"/bin/* ~/coreos-osx/bin
    chmod 755 ~/coreos-osx/bin/*
    cp -f "$1"/bin/corevm ~/bin

    # copy user-data
    cp -f "$1"/cloud-init/* ~/coreos-osx/cloud-init

    # copy settings
    cp -f "$1"/settings/* ~/coreos-osx/settings

    # check if iTerm.app exists
    App="/Applications/iTerm.app"
    if [ ! -d "$App" ]
    then
        unzip "$1"/files/iTerm2.zip -d /Applications/
    fi

    # check corectld server
    check_corectld_server

    # initial init
    open -a iTerm.app "$1"/first-init.command
