CoreOS-Vagrant GUI for Mac OS X
============================

CoreOS-Vagrant GUI for Mac OS X is a Mac Status bar App which works like a wrapper around the coreos-vagrant command line tool.
[CoreOS](https://coreos.com) is a Linux distribution made specifically to run [Docker](https://www.docker.io/) containers.
[CoreOS-Vagrant](https://github.com/coreos/coreos-vagrant) is made to run on VirtualBox and VMWare VMs.

![CoreOS-Vagrant-GUI L](coreos-vagrant-gui.png "CoreOS-Vagrant-GUI")

Download
--------
Head over to the [Releases Page](https://github.com/rimusz/coreos-osx-gui/releases) to grab the latest ZIP file with the ````App package````.


How to install
----------

Required software
* It needs ````VirtualBox for OS X```` to be present on the OS X.
If you do not have it, download [VirtualBox for Mac OS X hosts](https://www.virtualbox.org/wiki/Downloads) and install it.

* It needs ````Vagrant for OS X```` to be present on the OS X too.
If you do not have it, download [Vagrant for Mac OS X](http://www.vagrantup.com/downloads.html) and install it.

* It needs ````iTerm 2```` to be present on the OS X too.
If you do not have it, download [iTerm 2](http://www.iterm2.com/#/section/downloads) and install it.

* Download the ````CoreOS Vagrant OSX GUI latest.zip```` from the [Releases Page](https://github.com/rimusz/coreos-osx-gui/releases) and unzip it on to your Mac Desktop as otherwise install will fail (after the ````initial setup```` you can copy the App to whatever place you like)
* Start the ````CoreOS Vagrant OSX GUI```` and from menu ````Setup/Update```` choose ````Initial setup of CoreOS-Vagrant```` 
* and the install will do the following:
````
1) All dependent files/folders will be put under "coreos-osx" folder in the user's home folder
2) Will clone coreos-vagrant from git
3) user-data file will have fleet, etcd, [Docker Socket for the API](https://coreos.com/docs/launching-containers/building/customizing-docker) and [DockerUI](https://github.com/crosbymichael/dockerui) enabled
4) docker 4243 port will be set for docker OS X client to work properly
5) Will set VM IP to 172.17.8.99 for DockerUI to properly open in a web browser
6) Will download and install fleet, etcd and docker OS X clients to ~/coreos-osx/bin/
7) Will run vagrant up to initialise VM
8) Shared folder between host and VM will be created under ~/coreos-osx/share
9) Will forward 80, 9000 and docker ports pool (49000..49900) including 4243 from host to vagrant VM.
````

How it works
------------

Just start ````CoreOS Vagrant OSX GUI```` application and you will find a small icon with the CoreOS logo in the Status Bar.
For now it only supports a standalone CoreOS VM, cluster support might come at same stage later one.

* There you can ````Up````, ````Suspend````, ````Halt````, ````Reload```` CoreOS vagrant VM
* Under ````Up & OS shell```` OS Shell will be opened when ````vagrant up```` finishes up and will have such environment set:
````
DOCKER_HOST=tcp://localhost:4243
FLEETCTL_ENDPOINT=http://localhost"
Path to ~/coreos-osx/bin where docker, etcdclt and fleetctl binaries are stored
```` 
* ````Setup/Update```` ````Check for updates```` will update to the latest docker, etcdclt and fleetctl OS X clients
* ````SSH```` will open VM shell
* ````DockerUI```` will show all running containers and etc (it might take a bit of a time after install for it to work as it needs to download it's image)


TO-DOs
------

* Make sed to parse Vagrantfile with folder sharing, network IP and ports changes after git clone is done
* Make it easier to add/delete docker ports.


Other links
-----------
Also you might like my other [boot2docker GUI for OS X](https://github.com/rimusz/boot2docker-gui-osx) project for [boot2docker](https://github.com/boot2docker/boot2docker),
as I use both projects depending on the work I need to do.

