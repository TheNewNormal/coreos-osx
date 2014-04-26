#!/bin/bash

#  coreos-update.command
#  CoreOS GUI for OS X
#
#  Created by Rimantas on 01/04/2014.
#  Copyright (c) 2014 Rimantas Mocevicius. All rights reserved.


if [ "$1" = "docker" ]
then
    # download latest version docker file
    curl -o ~/bin/docker http://get.docker.io/builds/Darwin/x86_64/docker-latest
    # Mark it executable
    chmod +x ~/bin/docker

    ~/bin/docker version
fi




