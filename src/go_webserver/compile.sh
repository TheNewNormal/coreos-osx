#!/bin/bash

# compile coreos-osx-web from source

go build coreos-osx-web.go
mv -f coreos-osx-web ../bin
