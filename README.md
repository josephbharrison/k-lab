# K-Lab

## Description

Kubernetes Lab (K-Lab) is the starting point for developing python microservices.

## Category:

Microservice

## Supported Environments

The recommended (tested/supported) environment for developing microservices with the K-Lab project is based on your workstation's (metal) OS:

## Checklist

- [ ] Setup K-Lab
- [ ] Test Locally

## Setup K-Lab

Setup K-Lab in your native terminal, and then open the project in Pycharm.

```shell script
$ git clone <k-lab_URL> && cd k-lab/   # clone the project
$ git checkout -b <your_branch>        # create a branch for devlopering your microservice
$ ln -s $PWD/k-lab/kenv /usr/local/bin # create kenv symlink
$ kenv prep                            # create virtual env
```

## Test Locally

Start up the environment and containers in the PyCharm terminal.

```shell script
$ kenv up                               # start the container services
```

## Vagrant VM

### Native -> Terminal

```
$ git clone <k-lab_URL>   # clone the project
$ cd k-lab/vagrant        # change to vagrant directory
$ vagrant up              # start the VM

```

### Vagrant -> Terminal

```
$ cd code/k-lab # change k-lab directory
$ kenv prep -e http # setup venv and HTTP example, then reload term
$ charm . # open k-lab in PyCharm
```

... continue from 'Test Locally' from 'Native + PyCharm'
