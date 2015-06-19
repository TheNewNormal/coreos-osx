CoreOS-Vagrant GUI for OS X
============================

CoreOS-Vagrant GUI for Mac OS X is a Mac Status bar App which works like a wrapper around the [coreos-vagrant](https://github.com/coreos/coreos-vagrant) command line tool. It supports only a standalone CoreOS VM, cluster one is at [CoreOS-Vagrant Cluster GUI](https://github.com/rimusz/coreos-osx-gui-cluster).

Note: Fully supports etcd2 in all CoresOS channels.

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
* Download `CoreOS Vagrant OSX GUI latest.dmg` from the [Releases Page](https://github.com/rimusz/coreos-osx-gui/releases) and open it and drag the App e.g to your Desktop.
* Start the `CoreOS Vagrant OSX GUI` and from menu `Setup` choose `Initial setup of CoreOS-Vagrant` 
* The install will do the following:

````
1) All dependent files/folders will be put under "coreos-osx" folder in the user's home 
 folder e.g /Users/someuser/coreos-osx
2) Will clone latest coreos-vagrant from git
3) user-data file will have fleet, etcd, and Docker Socket for the API enabled
4) Will download latest vagrant VBox and run "vagrant up" to initialise VM with docker 2375 port pre-set for docker OS X client
5) Will set VM to static IP '172.19.8.99' 
6) Will download and install fleet, etcd and docker OS X clients to ~/coreos-osx/bin/
7) A small shell script "rkt" will be installed to ~/coreos-osx/bin/ which allows to call
 remote rkt binary on CoreOS VM with e.g rkt help
8) docker-exec script (docker exec -it $1 bash -c 'export TERM=xterm && bash') is installed 
 into ~/coreos-osx/bin/ too, which allows to enter container with just a simple command:
 docker-exec container_name 
9) Will upload any saved docker images from ~/coreos-osx/docker_images folder
10) Will install DockerUI and Fleet-UI via fleet unit files from ~/coreos-osx/fleet folder.
11) Via IP 172.19.8.99 you can access any port on CoreOS VM, no needs to put any port forwards 
 to Vagrantfile.
12) user-data file enables docker flag `--insecure-registry` to access insecure registries.
````

How it works
------------

Just start `CoreOS Vagrant OSX GUI` application and you will find a small icon with the CoreOS logo in the Status Bar.
For now it only supports a standalone CoreOS VM, cluster support might come at some stage later one.

* There you can `Up`, `Suspend`, `Halt`, `Reload` (usual vagrant commands) CoreOS vagrant VM
* `SSH to core-01` (vagrant ssh) will open VM shell
* Under `Up` OS Shell will be opened when `vagrant up` finishes and it will have such environment pre-set:
````
DOCKER_HOST=tcp://127.0.0.1:2375
ETCDCTL_PEERS=http://172.19.8.99:4001
FLEETCTL_ENDPOINT=http://172.19.8.99:4001
FLEETCTL_DRIVER=etcd
Path to ~/coreos-osx/bin where docker, etcdclt and fleetctl binaries and rkt shell 
script are stored
```` 

* `OS Shell` opens OS Shell with the same enviroment preset as `Up`
* `Upload docker images` will upload docker images from `~/coreos-osx/docker_images`, it saves time from downloading them again from Internet. If you destroy the VM and use `Up`, docker images will be automaticly uploaded to VM again.
* `Updates/Force CoreOS update` will run `sudo update_engine_client -update` on CoreOS VM.
* `Updates/Check for updates` will update docker, etcdclt and fleetctl OS X clients to the same versions as CoreOS VM runs. 
* [Fleet-UI](http://fleetui.com) dashboard will show running `fleet` units and etc (it might take a bit of a time after install for it to work, as it needs to download it's image)
* [DockerUI](https://github.com/crosbymichael/dockerui) will show all running containers and etc (it might take a bit of a time after install for it to work, as it needs to download it's image)
* Put your fleet units into `~/coreos-osx/my_fleet` and manually start them. If you destroy the VM and use `Up`, your fleet units will be automaticly deployed by `fleetctl`.
* This App has much automation as possible to make easier to destroy VM, change CoreOS release channel and get back to your previous setup in a fresh built VM with your saved docker images and fleet units.



Other links
-----------
* Cluster one CoreOS VM App can be found here [CoreOS-Vagrant Cluster GUI](https://github.com/rimusz/coreos-osx-gui-cluster).
* A standalone Kubernetes CoreOS VM App can be found here [CoreOS-Vagrant Kubernetes Solo GUI](https://github.com/rimusz/coreos-osx-gui-kubernetes-solo).
* Kubernetes Cluster one CoreOS VM App can be found here [CoreOS-Vagrant Kubernetes Cluster GUI ](https://github.com/rimusz/coreos-osx-gui-kubernetes-cluster).
