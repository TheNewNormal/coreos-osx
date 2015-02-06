CoreOS-Vagrant GUI for OS X
============================

CoreOS-Vagrant GUI for Mac OS X is a Mac Status bar App which works like a wrapper around the [coreos-vagrant](https://github.com/coreos/coreos-vagrant) command line tool. It supports only a standalone CoreOS VM, cluster one is at [CoreOS-Vagrant Cluster GUI](https://github.com/rimusz/coreos-osx-gui-cluster). Now includes Rocket too.
 
[CoreOS](https://coreos.com) is a Linux distribution made specifically to run [Docker](https://www.docker.io/) containers.
[CoreOS-Vagrant](https://github.com/coreos/coreos-vagrant) is made to run on VirtualBox and VMWare VMs.

![CoreOS-Vagrant-GUI L](coreos-vagrant-gui.png "CoreOS-Vagrant-GUI")

Download
--------
Head over to the [Releases Page](https://github.com/rimusz/coreos-osx-gui/releases) to grab the latest release.


How to install
----------

Required software
* [VirtualBox for Mac OS X hosts](https://www.virtualbox.org/wiki/Downloads), [Vagrant for Mac OS X](http://www.vagrantup.com/downloads.html) and [iTerm 2](http://www.iterm2.com/#/section/downloads)
* Download `CoreOS Vagrant OSX GUI latest.zip` from the [Releases Page](https://github.com/rimusz/coreos-osx-gui/releases) and unzip it.
* Start the `CoreOS Vagrant OSX GUI` and from menu `Setup` choose `Initial setup of CoreOS-Vagrant` 
* The install will do the following:
````
1) All dependent files/folders will be put under "coreos-osx" folder in the user's home folder e.g /Users/someuser/coreos-osx
2) Will clone latest coreos-vagrant from git
3) user-data file will have fleet, etcd, and Docker Socket for the API enabled
4) docker 2375 port will be set for docker OS X client to work properly
5) Will set VM to static IP '172.17.8.99' 
6) Will download and install fleet, etcd and docker OS X clients to ~/coreos-osx/bin/
7) A small shell script "rkt" will be installed to ~/coreos-osx/bin/ which allows to call remote rkt binary with e.g rkt help
8) Will download latest vagrant VBox and run vagrant up to initialise VM
9) Will forward 2375 (docker) from localhost to vagrant VM.
10) Will install DockerUI and Fleet-UI via fleet unit files from ~/coreos-osx/fleet folder.
11) Via IP 172.17.8.99 you can access any port on CoreOS VM, no needs to put port forwards to Vagrantfile.
````

How it works
------------

Just start `CoreOS Vagrant OSX GUI` application and you will find a small icon with the CoreOS logo in the Status Bar.
For now it only supports a standalone CoreOS VM, cluster support might come at some stage later one.

* There you can `Up`, `Suspend`, `Halt`, `Reload` CoreOS vagrant VM
* Under `Up` OS Shell will be opened when `vagrant up` finishes and it will have such environment set:
````
DOCKER_HOST=tcp://127.0.0.1:2375
ETCDCTL_PEERS=http://172.17.8.99:4001
FLEETCTL_ENDPOINT=http://172.17.8.99:4001
Path to ~/coreos-osx/bin where docker, etcdclt and fleetctl binaries and rkt shell script are stored
```` 
* `OS Shell` opens OS Shell with the same enviroment preset as `Up`
* `Updates/Force CoreOS update` will run `sudo update_engine_client -update` on CoreOS VM.
* `Updates/Check for updates` will update docker, etcdclt and fleetctl OS X clients to the same versions as CoreOS VM runs. It will store downloads from github `coreos-vagrant` in `~/coreos-osx/github` folder, it will not overwrite user's `Vagrantfile, config.rb and users-data` files.
* `SSH` will open VM shell
* [Fleet-UI](http://fleetui.com) will show running fleet units and etc (it might take a bit of a time after install for it to work as it needs to download it's image
* [DockerUI](https://github.com/crosbymichael/dockerui) will show all running containers and etc (it might take a bit of a time after install for it to work as it needs to download it's image)
* Also user-data file enables with the flag `--insecure-registry` as per [CoreOS Blog](https://coreos.com/blog/docker-1-3-2-security-update/) Docker access to insecure private registries.
* On each `Up` and `Reload` fleet unit files placed into `~/coreos-osx/fleet` folder will be reloaded and restarted, it is very handy when you used `Destroy VM` and want your fleet units to be used again.


Other links
-----------
* Cluster one CoreOS VM App can be found here [CoreOS-Vagrant Cluster GUI](https://github.com/rimusz/coreos-osx-gui-cluster).
* Kubernetes Cluster one CoreOS VM App can be found here [CoreOS-Vagrant Kubernetes Cluster GUI ](https://github.com/rimusz/coreos-osx-gui-kubernetes-cluster).

