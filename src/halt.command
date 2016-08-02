#!/bin/bash

#  halt.command

# get App's Resources folder
res_folder=$(cat ~/coreos-osx/.env/resouces_path)

# path to the bin folder where we store our binary files
export PATH=${HOME}/coreos-osx/bin:$PATH

# send halt to VM
~/bin/corectl halt core-01

