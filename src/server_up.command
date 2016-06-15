#!/bin/bash

# server_up.command
#

#
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${DIR}"/functions.sh

sudo corectl server -u $USER --start >/dev/null 2>&1 &
