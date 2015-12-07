#!/bin/bash

#  ssh.command

# path to the bin folder where we store our binary files
export PATH=${HOME}/coreos-osx/bin:$PATH

# ssh into VM
corectl ssh core-01
