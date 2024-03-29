# K-Lab

Kubernetes Lab (K-Lab) provides local develop environment automation for microservices.

## Usage

```sh
Usage:
  kenv <command> [opts]

Commands:
  build                                    build containers
  clean                                    reset the environment
  down                                     bring environment down
  prep                                     prepare venv only
  up                                       bring environment up

Options:
  -h | --help                              help information (this output)
  -m | --mode <local|docker>               (default: local)
  -t | --tag                               python venv version (default: 3.8.5)
  -v | --verbose                           verbose output (if available)
```

## Setup K-Lab

Setup K-Lab in your native terminal, and then open the project in Pycharm.

```sh
git clone git@github.com:josephbharrison/k-lab.git  # clone repo
ln -s $PWD/k-lab/kenv /usr/local/bin                # create kenv symlink
kenv prep                                           # create python virtual env
```

## Test Locally

Start up the environment and containers in the PyCharm terminal.

```sh
nvim .env.local                                     # local vars, COMPOSE="redis etcd"
kenv up                                             # start the container services
```

## Vagrant VM

### Native Terminal

```sh
git clone <k-lab_URL>                               # clone the project
cd k-lab/vagrant                                    # change to vagrant directory
vagrant up                                          # start the VM
```

### Vagrant Terminal

```sh
cd code/k-lab                                       # change k-lab directory
kenv prep                                           # setup venv
nvim .                                              # open k-lab in PyCharm
```
