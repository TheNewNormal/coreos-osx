#!/bin/bash

#  iTerm-shell.command
#  CoreOS GUI for OS X
#
#  Created by Rimantas on 01/04/2014.
#  Copyright (c) 2014 Rimantas Mocevicius. All rights reserved.

# Set the environment variable for the docker daemon
eval $(echo "export DOCKER_HOST=tcp://localhost:4243")

# path to the bin folder where we store our binary files
eval $(echo "export PATH=$PATH:${HOME}/coreos-osx/bin")

open -a iTerm.app ~/coreos-osx/bin/shell.command

