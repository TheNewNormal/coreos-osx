CoreOS-Vagrant GUI for Mac OS X
============================

CoreOS Vagrant GUI for Mac OS X is a Mac Status bar App which works like a wrapper around the coreos-vagrant command line tool.
[CoreOS Vagrant](https://github.com/coreos/coreos-vagrant) is a Linux distribution made specifically to run [Docker](https://www.docker.io/) containers.

![CoreOS-Vagrant-GUI L](coreos-vagrant-gui.png "CoreOS-Vagrant-GUI")

Download
--------
Head over to the [Releases Page](https://github.com/rimusz/coreos-osx-gui/releases) to grab the latest ZIP file with the ````App package````.


How to install
----------

* It needs ````VirtualBox for OS X```` to be present on the OS X.
If you do not have it, download [VirtualBox for Mac OS X hosts](https://www.virtualbox.org/wiki/Downloads) and install it.

* It needs ````Vagrant for OS X```` to be present on the OS X too.
If you do not have it, download [Vagrant for Mac OS X](http://www.vagrantup.com/downloads.html) and install it.

* Install [CoreOS Vagrant](https://github.com/coreos/coreos-vagrant).

* Unzip the ````CoreOS Vagrant OSX GUI latest.zip```` and copy the App to whatever place you like.

How it works
------------

Just start ````CoreOS Vagrant OSX GUI```` application and you will find a small icon with the CoreOS logo in the Status Bar.

* There you can ````Up````, ````Suspend````, ````Halt````, ````Reload```` CoreOS vagrant VM
* ````Update```` ````docker OS X client```` will install/update to the latest docker OS X client
* Your ````.bash_profile```` needs ````export DOCKER_HOST=tcp://localhost:4243````
* Your coreos-vagrant must have [enabled the remote API](https://coreos.com/docs/launching-containers/building/customizing-docker) 


TO-DOs
------

* Make to work an option to open ````vagrant ssh```` in terminal from the menu
* Make to work an option to open ````OS shell```` in terminal from the menu
* Make to work [DockerUI](https://github.com/crosbymichael/dockerui) from the menu

