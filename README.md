CoreOS VM for OS X 
========================

***CoreOS VM for OS X App has a new home, it is now under https://github.com/TheNewNormal organisation***

**CoreOS VM for OS X** (coreos-machine) is a Mac Status bar App which works like a wrapper around the [corectl](https://github.com/TheNewNormal/corectl) command line tool (it makes easier to control [xhyve](https://github.com/xhyve-xyz/xhyve) based VMs). 

It includes [Docker Registry v2](https://github.com/docker/distribution) (Go based and compiled for OS X)

It supports only a standalone CoreOS VM, cluster one (Vagrant based) is at [CoreOS Cluster for OS X](https://github.com/rimusz/coreos-osx-cluster).

**New** v1.1.0 is based on [corectl](https://github.com/TheNewNormal/corectl) which brings more stablity to the App. App got renamed from `CoreOS GUI` to `CoreOS`. Mac user home folder is automaticly mounted to VM.


![CoreOS-OSX](coreos-osx-gui.png "CoreOS-OSX-GUI")


How to install CoreOS VM for OS X
----------

**Requirements**
 -----------
  - **OS X 10.10.3** Yosemite or later 
  - Mac 2010 or later for this to work.
  - Vagrant if you want to mount your Mac user folder inside your CoreOS VM
  - If you want to use this App with any other VirtualBox based VM, you need to use newest versions of VirtualBox 4.3.x or 5.0.x.


####Download:
* Download `CoreOS OSX latest.dmg` from the [Releases Page](https://github.com/TheNewNormal/coreos-osx/releases)

###Install:

Open downloaded `dmg` file and drag the App e.g. to your Desktop. Start the `CoreOS OSX` and `Initial setup of CoreOS OSX` will run.

**TL;DR**

- App's files are installed to `~/coreos-osx` folder
- CoreOS ISO files are stored under `~/.coreos` folder
- Docker registry runs on `192.168.64.1:5000` and images are stored under `~/coreos-osx/registry`
- Mac user home folder is automaticly mounted to VM: `/Users/my_user`:`/Users/my_user`
- OS X `fleetctl` and `docker` clients are installed to `~/coreos-osx/bin` and preset in `OS shell` to be used from there

**The install will do the following:**

- All dependent files/folders will be put under `coreos-osx` folder in the user's home folder e.g /Users/someuser/coreos-osx
- Mac user home folder is automaticly mounted to VM: `/Users/my_user` can be accessed on VM via the same `/Users/my_user`, it is very handy for using docker mounted volumes 
- User's Mac password will be stored in `OS X Keychain`, it will be used to pass to `sudo` command which needs to be used starting the VM, this allows to avoid using `sudo` for `corectl` to start a VM. 
- ISO images are stored under `~/.coreos/images`
That allows to share the same images between different `corectl` based Apps and also speeds up this App VMs reinstall
- user-data file will have fleet, etcd, and Docker Socket for the API enabled
- Will download latest CoreOS ISO image and run `corectl` to initialise VM with docker 2375 port pre-set for docker OS X client
- Will download and install `fleetctl` and `docker` OS X clients to ~/coreos-osx/bin/
- A small shell script `rkt` will be installed to ~/coreos-osx/bin/ which allows to call via ssh remote `rkt` binary on CoreOS VM
- A small shell script `etcdctl` will be installed to ~/coreos-osx/bin/ which allows to call via ssh remote `etcdctl` binary on CoreOS VM
- `docker-exec` script (docker exec -it $1 bash -c 'export TERM=xterm && bash') will be installed 
 into ~/coreos-osx/bin/ too, which allows to enter container with just a simple command:
 docker-exec container_name 
- Also `docker2aci` binary will be installed to ~/coreos-osx/bin/, which allows to convert docker images to `rkt` aci images
- Will install [Fleet-UI](http://fleetui.com) and [DockerUI](https://github.com/crosbymichael/dockerui) via unit files
- Via assigned static IP (it will be shown in first boot and will survive VM's reboots) you can access any port on CoreOS VM
- user-data file enables docker flag `--insecure-registry` to access insecure registries.
- Root persistant disk will be created and mounted to `/` so data will survive VM reboots. 


How it works
------------

Just start `CoreOS OSX GUI ` application and you will find a small icon with the CoreOS logo with `h`in the Status Bar.

* There you can `Up`, `Halt`, `Reload` CoreOS VM
* `SSH to core-01` (vagrant ssh) will open VM shell. Note this requires [Vagrant](https://www.vagrantup.com/) to be installed
* Under `Up` OS Shell will be opened when VM boot finishes up and it will have such environment pre-set:

```
DOCKER_HOST=tcp://192.168.64.xxx:2375
ETCDCTL_PEERS=http://192.168.64.xxx:2379
FLEETCTL_ENDPOINT=http://192.168.64.xxx:2379
FLEETCTL_DRIVER=etcd
```
```
Path to `~/coreos-osx/bin` where docker and fleetctl binaries, rkt, etcdclt 
and docker-exec shell scripts are stored
```

* `OS Shell` opens OS Shell with the same enviroment preset as `Up`
* `Updates/Check updates for OS X fleetctl and docker clients` will update fleet and docker OS X clients to the same versions as CoreOS VM runs.
* `Updates/Fetch latest CoreOS ISO` will download the lasted CoreOS ISO file for the currently set release channel. 
* [Fleet-UI](http://fleetui.com) dashboard will show running `fleet` units and etc
* [DockerUI](https://github.com/crosbymichael/dockerui) will show all running containers and etc
* Put your fleet units into `~/coreos-osx/my_fleet` folder and they will be automaticly started on each VM boot.
* You can upload your saved/exported docker images place in `~/coreos-osx/docker_images` folder via `Upload docker images`
* Local Docker Registry v2 (Go based and compiled for  OS X) is running on `192.168.64.1:5000`, which gets started/stopped on each VM Up/Halt.
* This App has as much automation as possible to make easier to use CoreOS on OS X, e.g. you can change CoreOS release channel and reload VM as `root` persistant disk for VM will be created and mounted to `/` so data will survive VM reboots.

Troubleshooting
-----------

**Mac user folder fails to mount inside the CoreOS VM**

If you have not installed [Vagrant](https://www.vagrantup.com/), when you SSH into your CoreOS VM you will see the following message:

```
bash-3.2$ /Applications/CoreOS.app/Contents/Resources/ssh.command; exit;
Last login: Sat Jan  9 05:03:57 2016 from 192.168.64.1
CoreOS stable (835.9.0)
Update Strategy: No Reboots
Failed Units: 1
  Users.mount
```

Nothing will be mounted under ``/Users``. To fix this, exit, download and install Vagrant and try it again. If successful the ``Failed Units`` message will no longer appear and the contents of your Mac ``/Users/`` folder will appear under ``/Users/`` in your shell.

Credits
-----------
* To [António Meireles](https://github.com/AntonioMeireles) for his awesome [corectl](https://github.com/TheNewNormal/corectl) tool to easily control [xhyve](https://github.com/xhyve-xyz/xhyve)
* To [Michael Steil](https://github.com/mist64) for the awesome [xhyve](https://github.com/mist64/xhyve) lightweight OS X virtualization solution
* To Kelsey Hightower for [Docker Registry OS X Setup Guide](https://github.com/kelseyhightower/docker-registry-osx-setup-guide).


Other CoreOS VM based Apps
-----------
* Cluster one CoreOS VM App can be found here [CoreOS Cluster for OS X](https://github.com/rimusz/coreos-osx-cluster).
* Kubernetes Solo Cluster VM App (corectl based) can be found here [Kube Solo for OS X](https://github.com/TheNewNormal/kube-solo-osx).
* Kubernetes Cluster one CoreOS VM App can be found here [CoreOS Kubernetes Cluster for OS X ](https://github.com/rimusz/coreos-osx-kubernetes-cluster).
