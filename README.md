# K-Lab

## Description

Kubernetes Lab (K-Lab) provides local develop environment setup for microservices.

## Usage

```sh
Usage:
  kenv <command> [opts]

Commands:
  build                                    build containers
  clean                                    reset the environment
  clone <target>                           clone current project to target
  down                                     bring environment down
  prep                                     prepare venv only
  up                                       bring environment up

Options:
  -e | --example <app>                     setup example environment
  -h | --help                              help information (this output)
  -m | --mode <local|docker>               (default: local)
  -t | --tag                               python venv version (default: 3.8.5)
  -v | --verbose                           verbose output (if available)
```

## Setup K-Lab

Setup K-Lab in your native terminal, and then open the project in Pycharm.

```sh
$ git clone <k-lab_URL> && cd k-lab/    # clone the project
$ ln -s $PWD/k-lab/kenv /usr/local/bin  # create kenv symlink
$ kenv prep                             # create python virtual env
```

## Test Locally

Start up the environment and containers in the PyCharm terminal.

```sh
$ nvim .env.local                       # add service deps, e.g. COMPOSE="redis etcd"
$ kenv up                               # start the container services
```

## Vagrant VM

### Native Terminal

```sh
$ git clone <k-lab_URL>                 # clone the project
$ cd k-lab/vagrant                      # change to vagrant directory
$ vagrant up                            # start the VM
```

### Vagrant Terminal

```sh
$ cd code/k-lab                         # change k-lab directory
$ kenv prep                             # setup venv and HTTP example, then reload term
$ nvim .                                # open k-lab in PyCharm
```

... continue from 'Test Locally' from 'Native + PyCharm'
