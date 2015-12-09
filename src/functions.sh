#!/bin/bash

# shared functions library

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )


function pause(){
    read -p "$*"
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
        sed -i "" 's/channel = "stable"/channel = "alpha"/g' ~/coreos-osx/settings/*.toml
        sed -i "" 's/channel = "beta"/channel = "alpha"/g' ~/coreos-osx/settings/*.toml
        channel="Alpha"
        LOOP=0
    fi

    if [ $RESPONSE = 2 ]
    then
        VALID_MAIN=1
        sed -i "" 's/channel = "stable"/channel = "beta"/g' ~/coreos-osx/settings/*.toml
        sed -i "" 's/channel = "alpha"/channel = "beta"/g' ~/coreos-osx/settings/*.toml
        channel="Beta"
        LOOP=0
    fi

    if [ $RESPONSE = 3 ]
    then
        VALID_MAIN=1
        sed -i "" 's/channel = "beta"/channel = "stable"/g' ~/coreos-osx/settings/*.toml
        sed -i "" 's/channel = "alpha"/channel = "stable"/g' ~/coreos-osx/settings/*.toml
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
# path to the bin folder where we store our binary files
export PATH=${HOME}/coreos-osx/bin:$PATH

# create persistent disk
cd ~/coreos-osx/
echo "  "
echo "Please type ROOT disk size in GBs followed by [ENTER]:"
echo -n "[default is 5]: "
read disk_size
if [ -z "$disk_size" ]
then
    echo " "
    echo "Creating 5GB disk ..."
    dd if=/dev/zero of=root.img bs=1024 count=0 seek=$[1024*5120]
else
    echo "Creating "$disk_size"GB disk (could take a while for big disks)..."
    dd if=/dev/zero of=root.img bs=1024 count=0 seek=$[1024*$disk_size*1024]
fi
#

### format ROOT disk

# Get password
my_password=$(security find-generic-password -wa coreos-osx-app)
# reset sudo
sudo -k > /dev/null 2>&1
#
echo -e "$my_password\n" | sudo -Sv > /dev/null 2>&1
#
echo " "
echo "Formating core-01 ROOT disk ..."


## start VM

# option 1
# get UUID
UUID=$(cat ~/coreos-osx/settings/core-01.toml | grep "uuid =" | sed -e 's/uuid = "\(.*\)"/\1/' | tr -d ' ')
# cleanup
rm -rf ~/.coreos/running/$UUID
# start VM
sudo "${res_folder}"/bin/corectl load settings/format-root.toml 2>&1 | grep IP | awk -v FS="(IP | and)" '{print $2}' | tr -d "\n" > ~/coreos-osx/.env/ip_address
spin='-\|/'
i=1
#while [[ "$('${res_folder}'/bin/corectl ps 2>&1 | grep '[c]ore-01')" != "" ]]
while [[ "$(corectl ps 2>&1 | grep '[c]ore-01')" != "" ]]
do
    printf "\r${spin:$i:1}"
    sleep .1
done

sleep 2

# cleanup
rm -rf ~/.coreos/running/$UUID

# option 2
#sudo "${res_folder}"/bin/corectl load settings/format-root.toml
#sleep 2
#while [[ "$("${res_folder}"/bin/corectl ps -j | jq ".[] | select(.Name==\"core-01\") | .Detached")" != "true" ]]
#do
#    sleep 1
#done
# get VM's IP
#corectl ps -j | jq ".[] | select(.Name==\"core-01\") | .PublicIP" | sed -e 's/"\(.*\)"/\1/' | tr -d "\n" > ~/coreos-osx/.env/ip_address
# halt VM
#sudo "${res_folder}"/bin/corectl halt core-01

echo " "
echo "ROOT disk got created and formated... "
echo "---"

}


function download_osx_clients() {
# download fleetctl file
LATEST_RELEASE=$(corectl ssh core-01 "fleetctl version" | cut -d " " -f 3- | tr -d '\r')
cd ~/coreos-osx/bin
echo "Downloading fleetctl v$LATEST_RELEASE for OS X"
curl -L -o fleet.zip "https://github.com/coreos/fleet/releases/download/v$LATEST_RELEASE/fleet-v$LATEST_RELEASE-darwin-amd64.zip"
unzip -j -o "fleet.zip" "fleet-v$LATEST_RELEASE-darwin-amd64/fleetctl"
rm -f fleet.zip
echo "fleetctl was copied to ~/coreos-osx/bin "
#

echo " "
# download docker file
DOCKER_VERSION=$(corectl ssh core-01 'docker version' | grep 'Server version:' | cut -d " " -f 3- | tr -d '\r' | sed 's/^[ \t]*//;s/[ \t]*$//' )

if [ "$DOCKER_VERSION" = "" ]
then
    DOCKER_VERSION=$(corectl ssh core-01 'docker version' | grep 'Version:' | cut -d " " -f 3- | tr -d '\r' | head -1 | sed 's/^[ \t]*//;s/[ \t]*$//' )
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
# save user's password to Keychain
echo "  "
echo "Your Mac user's password will be saved in to 'Keychain' "
echo "and later one used for 'sudo' command to start VM !!!"
echo " "
echo "This is not the password to access VM via ssh or console !!!"
echo " "
echo "Please type your Mac user's password followed by [ENTER]:"
read -s my_password
passwd_ok=0

# check if sudo password is correct
while [ ! $passwd_ok = 1 ]
do
    # reset sudo
    sudo -k
    # check sudo
    echo -e "$my_password\n" | sudo -Sv > /dev/null 2>&1
    CAN_I_RUN_SUDO=$(sudo -n uptime 2>&1|grep "load"|wc -l)
    if [ ${CAN_I_RUN_SUDO} -gt 0 ]
    then
        echo "The sudo password is fine !!!"
        echo " "
        passwd_ok=1
    else
        echo " "
        echo "The password you entered does not match your Mac user password !!!"
        echo "Please type your Mac user's password followed by [ENTER]:"
        read -s my_password
    fi
done

security add-generic-password -a coreos-osx-app -s coreos-osx-app -w $my_password -U

}


function clean_up_after_vm {
sleep 1

# path to the bin folder where we store our binary files
export PATH=${HOME}/coreos-osx/bin:$PATH

# get App's Resources folder
res_folder=$(cat ~/coreos-osx/.env/resouces_path)

# get password for sudo
my_password=$(security find-generic-password -wa coreos-osx-app)
# reset sudo
sudo -k
# enable sudo
echo -e "$my_password\n" | sudo -Sv > /dev/null 2>&1

# send halt to VM
sudo "${res_folder}"/bin/corectl halt core-01

# Stop docker registry
"${res_folder}"/docker_registry.sh stop
kill $(ps aux | grep "[r]egistry config.yml" | awk {'print $2'})

# kill all other scripts
pkill -f [C]oreOS GUI.app/Contents/Resources/fetch_latest_iso.command
pkill -f [C]oreOS GUI.app/Contents/Resources/update_osx_clients_files.command
pkill -f [C]oreOS GUI.app/Contents/Resources/change_release_channel.command

}

