#!/bin/bash

# shared functions library

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )


function pause(){
    read -p "$*"
}

function check_vm_status() {
# check VM status
status=$(ps aux | grep "[c]oreos-osx/bin/xhyve" | awk '{print $2}')
if [ "$status" = "" ]; then
    echo " "
    echo "CoreOS VM is not running, please start VM !!!"
    pause "Press any key to continue ..."
    exit 1
fi
}


function release_channel(){
# Set release channel
LOOP=1
while [ $LOOP -gt 0 ]
do
    VALID_MAIN=0
    echo " "
    echo "Set CoreOS Release Channel:"
    echo " 1)  Alpha "
    echo " 2)  Beta "
    echo " 3)  Stable "
    echo " "
    echo -n "Select an option: "

    read RESPONSE
    XX=${RESPONSE:=Y}

    if [ $RESPONSE = 1 ]
    then
        VALID_MAIN=1
        sed -i "" "s/CHANNEL=stable/CHANNEL=alpha/" ~/coreos-osx/custom.conf
        sed -i "" "s/CHANNEL=beta/CHANNEL=alpha/" ~/coreos-osx/custom.conf
        channel="Alpha"
        LOOP=0
    fi

    if [ $RESPONSE = 2 ]
    then
        VALID_MAIN=1
        sed -i "" "s/CHANNEL=alpha/CHANNEL=beta/" ~/coreos-osx/custom.conf
        sed -i "" "s/CHANNEL=stable/CHANNEL=beta/" ~/coreos-osx/custom.conf
        channel="Beta"
        LOOP=0
    fi

    if [ $RESPONSE = 3 ]
    then
        VALID_MAIN=1
        sed -i "" "s/CHANNEL=alpha/CHANNEL=stable/" ~/coreos-osx/custom.conf
        sed -i "" "s/CHANNEL=beta/CHANNEL=stable/" ~/coreos-osx/custom.conf
        channel="Stable"
        LOOP=0
    fi

    if [ $VALID_MAIN != 1 ]
    then
        continue
    fi
done
}


create_root_disk() {
# create persistent disk
cd ~/coreos-osx/
echo "  "
echo "Please type ROOT disk size in GBs followed by [ENTER]:"
echo -n [default is 5]:
read disk_size
if [ -z "$disk_size" ]
then
    echo "Creating 5GB disk ..."
    dd if=/dev/zero of=root.img bs=1024 count=0 seek=$[1024*5120]
else
    echo "Creating "$disk_size"GB disk ..."
    dd if=/dev/zero of=root.img bs=1024 count=0 seek=$[1024*$disk_size*1024]
fi
echo " "
#

### format ROOT disk
# Start webserver
cd ~/coreos-osx/cloud-init
"${res_folder}"/bin/webserver start

# Get password
my_password=$(cat ~/coreos-osx/.env/password | base64 --decode )
echo -e "$my_password\n" | sudo -S ls > /dev/null 2>&1

# Start VM
echo "Waiting for VM to boot up for ROOT disk to be formated ... "
cd ~/coreos-osx
export XHYVE=~/coreos-osx/bin/xhyve

# enable format mode
sed -i "" "s/user-data/user-data-format-root/" ~/coreos-osx/custom.conf
sed -i "" "s/ROOT_HDD=/#ROOT_HDD=/" ~/coreos-osx/custom.conf
sed -i "" "s/#IMG_HDD=/IMG_HDD=/" ~/coreos-osx/custom.conf
#
"${res_folder}"/bin/coreos-xhyve-run -f custom.conf coreos-osx
#
# disable format mode
sed -i "" "s/user-data-format-root/user-data/" ~/coreos-osx/custom.conf
sed -i "" "s/IMG_HDD=/#IMG_HDD=/" ~/coreos-osx/custom.conf
sed -i "" "s/#ROOT_HDD=/ROOT_HDD=/" ~/coreos-osx/custom.conf
#

echo " "
echo "ROOT disk got created and formated... "
echo " "

# Stop webserver
"${res_folder}"/bin/webserver stop
###

}

function download_osx_clients() {
# download fleetctl file
LATEST_RELEASE=$(ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no core@$vm_ip 'fleetctl version' | cut -d " " -f 3- | tr -d '\r')
cd ~/coreos-osx/bin
echo "Downloading fleetctl v$LATEST_RELEASE for OS X"
curl -L -o fleet.zip "https://github.com/coreos/fleet/releases/download/v$LATEST_RELEASE/fleet-v$LATEST_RELEASE-darwin-amd64.zip"
unzip -j -o "fleet.zip" "fleet-v$LATEST_RELEASE-darwin-amd64/fleetctl"
rm -f fleet.zip
echo "fleetctl was copied to ~/coreos-osx/bin "
#

echo " "
# download docker file
DOCKER_VERSION=$(ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no core@$vm_ip  'docker version' | grep 'Server version:' | cut -d " " -f 3- | tr -d '\r' | sed 's/^[ \t]*//;s/[ \t]*$//' )

if [ "$DOCKER_VERSION" = "" ]
then
    DOCKER_VERSION=$(ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no core@$vm_ip  'docker version' | grep 'Version:' | cut -d " " -f 3- | tr -d '\r' | head -1 | sed 's/^[ \t]*//;s/[ \t]*$//' )
fi

CHECK_DOCKER_RC=$(echo $DOCKER_VERSION | grep rc)
if [ -n "$CHECK_DOCKER_RC" ]
then
    # docker RC release
    if [ -n "$(curl -s --head https://test.docker.com/builds/Darwin/x86_64/docker-$DOCKER_VERSION | head -n 1 | grep "HTTP/1.[01] [23].." | grep 200)" ]
    then
        # we check if RC is still available
        echo "Downloading docker $DOCKER_VERSION client for OS X"
        curl -o ~/coreos-osx/bin/docker https://test.docker.com/builds/Darwin/x86_64/docker-$DOCKER_VERSION
    else
        # RC is not available anymore, so we download stable release
        DOCKER_VERSION_STABLE=$(echo $DOCKER_VERSION | cut -d"-" -f1)
        echo "Downloading docker $DOCKER_VERSION_STABLE client for OS X"
        curl -o ~/coreos-osx/bin/docker https://get.docker.com/builds/Darwin/x86_64/docker-$DOCKER_VERSION_STABLE
    fi
else
    # docker stable release
    echo "Downloading docker $DOCKER_VERSION client for OS X"
    curl -o ~/coreos-osx/bin/docker https://get.docker.com/builds/Darwin/x86_64/docker-$DOCKER_VERSION
fi
# Make it executable
chmod +x ~/coreos-osx/bin/docker
echo "docker was copied to ~/coreos-osx/bin"
}


function check_for_images() {
# Check if set channel's images are present
CHANNEL=$(cat ~/coreos-osx/custom.conf | grep CHANNEL= | head -1 | cut -f2 -d"=")
LATEST=$(ls -r ~/coreos-osx/imgs/${CHANNEL}.*.vmlinuz | head -n 1 | sed -e "s,.*${CHANNEL}.,," -e "s,.coreos_.*,," )
if [[ -z ${LATEST} ]]; then
    echo "Couldn't find anything to load locally (${CHANNEL} channel)."
    echo "Fetching lastest $CHANNEL channel ISO ..."
    echo " "
    cd ~/coreos-osx/
    "${res_folder}"/bin/coreos-xhyve-fetch -f custom.conf
fi
}


function deploy_fleet_units() {
# deploy fleet units from ~/coreos-osx/fleet
if [ "$(ls ~/coreos-osx/fleet | grep -o -m 1 service)" = "service" ]
then
    cd ~/coreos-osx/fleet
    echo "Starting all fleet units in ~/coreos-osx/fleet:"
    fleetctl submit *.service
    fleetctl start *.service
    echo " "
fi
}

function deploy_my_fleet_units() {
# deploy fleet units from ~/coreos-osx/fleet
if [ "$(ls ~/coreos-osx/my_fleet | grep -o -m 1 service)" = "service" ]
then
    cd ~/coreos-osx/my_fleet
    echo "Starting all fleet units in ~/coreos-osx/my_fleet:"
    fleetctl start *.service
    echo " "
fi
}


function save_password {
# save user password to file
echo "  "
echo "Your Mac user password will be saved to '~/coreos-osx/.env/password' "
echo "and later one used for 'sudo' commnand to start VM !!!"
echo "Please type your Mac user's password followed by [ENTER]:"
read -s password
echo -n ${password} | base64 > ~/coreos-osx/.env/password
chmod 600 ~/coreos-osx/.env/password
echo " "
}

