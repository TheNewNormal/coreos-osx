#!/bin/bash

#  coreos-vagrant.command
#  CoreOS GUI for OS X
#
#  Created by Rimantas on 01/04/2014.
#  Copyright (c) 2014 Rimantas Mocevicius. All rights reserved.

# overwrite for OS X 10.11
vagrant=/usr/local/bin/vagrant

# pass first argument - up, halt ...
cd ~/coreos-osx/coreos-vagrant
$vagrant $1
