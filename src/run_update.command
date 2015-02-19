#!/bin/bash

#  run_update.command
#  CoreOS GUI for OS X
#
#  Created by Rimantas on 01/04/2014.
#  Copyright (c) 2014 Rimantas Mocevicius. All rights reserved.

    # cd to App's Resources folder
    cd "$1"

    # call script
    open -a iTerm.app "$1"/update.command "$1"
