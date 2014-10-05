#!/bin/bash -x

gsed -i "/# plugin conflict/r Vagrantfile.parallels" Vagrantfile
sed -i "" 's/# plugin conflict/#/' Vagrantfile
