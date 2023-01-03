# K-lab / Vagrant Setup

## Documentation for setting up Vagrant to use our Ubuntu based Kailash Developer Workstation.

## Requirements:

1-You need to have Virtualbox installed.  You can download it from here: https://www.virtualbox.org/wiki/Downloads

2-You need to have Vagrant installed.  You can download vagrant here: https://www.vagrantup.com/downloads.html


## Procedure:

1-On your windows machine, someplace with about 100GB+ free space, create a directory and copy the Vagrantfile to that location.

2-Running the following command 'vagrant up' to start the virtual machine.  This process will pull down the kailash image, and import it into your vagrant environment.   

3-You will need to add your own SSH keys:

```console
$ ssh-keygen -t rsa
# copy your id_rsa.pub to gitlab -> settings -> ssh keys
```


```console
C:\Users\USERNAME\Vagrant>vagrant up
Bringing machine 'default' up with 'virtualbox' provider...
==> default: Box 'kailash' could not be found. Attempting to find and install...
    default: Box Provider: virtualbox
    default: Box Version: >= 0
==> default: Box file was not detected as metadata. Adding it directly...
==> default: Adding box 'kailash' (v0) for provider: virtualbox
    default: Downloading: https://*****:*****@repo.kailash.windstream.net/repository/vagrant/boxes/kailash.box
==> default: Box download is resuming from prior download progress
    default:
==> default: Successfully added box 'kailash' (v0) for 'virtualbox'!
==> default: Importing base box 'kailash'...
==> default: Matching MAC address for NAT networking...
==> default: Setting the name of the VM: Vagrant_default_1567546810030_68560
==> default: Clearing any previously set network interfaces...
==> default: Preparing network interfaces based on configuration...
    default: Adapter 1: nat
==> default: Forwarding ports...
    default: 22 (guest) => 2222 (host) (adapter 1)
==> default: Running 'pre-boot' VM customizations...
==> default: Booting VM...
==> default: Waiting for machine to boot. This may take a few minutes...
    default: SSH address: 127.0.0.1:2222
    default: SSH username: vagrant
    default: SSH auth method: private key
    default:
    default: Vagrant insecure key detected. Vagrant will automatically replace
    default: this with a newly generated keypair for better security.
    default:
    default: Inserting generated public key within guest...
    default: Removing insecure key from the guest if it's present...
    default: Key inserted! Disconnecting and reconnecting using new SSH key...
==> default: Machine booted and ready!
==> default: Checking for guest additions in VM...
==> default: Mounting shared folders...
    default: /vagrant => C:/Users/USERNAME/Vagrant
```

You can test direct ssh access into the running vagrant instance by doing the following:

```console

C:\Users\USERNAME\Vagrant>vagrant ssh
Welcome to Ubuntu 19.04 (GNU/Linux 5.0.0-27-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

 * Congrats to the Kubernetes community on 1.16 beta 1! Now available
   in MicroK8s for evaluation and testing, with upgrades to RC and GA

     snap info microk8s

222 updates can be installed immediately.
117 of these updates are security updates.

vagrant@kailash-dev:~$ cd code
-bash: cd: code: No such file or directory
vagrant@kailash-dev:~$ sudo su -
root@kailash-dev:~# su - kailash
kailash@kailash-dev:~$ cd code
kailash@kailash-dev:~/code$ cd k-lab/
kailash@kailash-dev:~/code/k-lab$ pwd
/home/kailash/code/k-lab
kailash@kailash-dev:~/code/k-lab$ ls
app.py  charts  consumer.py  docker-compose  Dockerfile  env  examples  plugins  requirements.txt  test  venv
kailash@kailash-dev:~/code/k-lab$ cd ..
kailash@kailash-dev:~/code$ cd subscriber-test-tools/
kailash@kailash-dev:~/code/subscriber-test-tools$ ls
Dockerfile  env_setup.sh  lib  README.md  requirements.txt  setup.py  subctl
kailash@kailash-dev:~/code/subscriber-test-tools$                                           

```


