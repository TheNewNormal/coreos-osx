CoreOS-Vagrant GUI for Mac OS X
============================

CoreOS-Vagrant GUI for Mac OS X is a Mac Status bar App which works like a wrapper around the coreos-vagrant command line tool.
[CoreOS Vagrant](https://github.com/coreos/coreos-vagrant) is a Linux distribution made specifically to run [Docker](https://www.docker.io/) containers.

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

* Download the ````CoreOS Vagrant OSX GUI latest.zip```` from the [Releases Page](https://github.com/rimusz/coreos-osx-gui/releases) and unzip it on to your Mac Desktop as otherwise install will not work (after the ````initial setup```` you can copy the App to whatever place you like)
* Start the ````CoreOS Vagrant OSX GUI```` and from menu ````Setup/Update```` choose ````Initial setup of CoreOS-Vagrant```` 
* and the install will do the following:
````
1) All dependent file will be put under coreos-osx folder in the user's home folder
2) Will clone coreos-vagrant from git
3) user-data file will have fleet, etcd, [Docker Socket for the API](https://coreos.com/docs/launching-containers/building/customizing-docker) and [DockerUI](https://github.com/crosbymichael/dockerui) enabled
4) docker 4243 port will be set for docker OS X client to work properly
5) Will set VM IP to 172.17.8.99 for DockerUI to properly open in a web browser
6) Will download and install docker OS X client to ~/coreos-osx/bin/
7) Will run vagrant up to initialise VM
8) Shared folder between host and VM will be created under ~/coreos-osx/share
````

How it works
------------

Just start ````CoreOS Vagrant OSX GUI```` application and you will find a small icon with the CoreOS logo in the Status Bar.

* There you can ````Up````, ````Suspend````, ````Halt````, ````Reload```` CoreOS vagrant VM
* ````Update```` ````docker OS X client```` will update to the latest docker OS X client
* ````Vagrant ssh```` will open VM shell
* ````OS shell```` will have ````export DOCKER_HOST=tcp://localhost:4243```` set
* ````DockerUI```` will show all running containers and etc (it might take a bit of a time after install for it to work as it needs to download itself)


TO-DOs
------

* Make sed to parse Vagrantfile with folder sharing, network IP and ports changes after git clone is done

