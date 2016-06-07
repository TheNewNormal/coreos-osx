#!/bin/bash
# docker registry for coreos-osx vm

# path to the bin folder where we store our binary files
export PATH=${HOME}/coreos-osx/bin:$PATH

start() {
    echo "Starting Docker Registry v2 on 192.168.64.1:5000 ..."
    nohup registry serve config.yml >/dev/null 2>&1 &
}

stop() {
    kill $(ps aux | grep "[r]egistry serve config.yml" | awk {'print $2'}) >/dev/null 2>&1
}

usage() {
    echo "Usage: docker_registry.sh start|stop"
}

case "$1" in
        start)
                start
                ;;
        stop)
                stop
                ;;
        *)
                usage
                ;;
esac

