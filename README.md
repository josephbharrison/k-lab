# K-Lab

## Description

Kubernetes Lab (K-Lab) is the starting point for developing python microservices.

## Category:

Microservice

## Supported Environments

The recommended (tested/supported) environment for developing microservices with the K-Lab project is based on your workstation's (metal) OS:

- Mac OS X -> **Native + PyCharm**
- Ubuntu Linux -> **Native + PyCharm**
- Fedora Linux -> **Native + PyCharm**
- Other Linux -> **Native + Pycharm** or **Vagrant VM**
- Windows (any version) -> **Vagrant VM**

> NOTE:
>
> - IntelliJ IDE should work, but results may vary.
> - NodeJS/GoLang support soon to be released (the recommended IDE is TBD)

## Native + PyCharm

#### Checklist

- [ ] Setup K-Lab
- [ ] Test Locally
- [ ] Test Deployment
- [ ] Clone Project

### Setup K-Lab

Setup K-Lab in your native terminal, and then open the project in Pycharm.

```shell script
$ git clone <k-lab_URL> && cd k-lab/   # clone the project
$ git checkout -b <your_branch>        # create a branch for devlopering your microservice
$ ./env prep -e http                   # setup venv and HTTP example, then reload term
$ charm .                              # open k-lab in PyCharm
```

### Test Locally

Start up the environment and containers in the PyCharm terminal.

> **Pycharm -> View -> Windows -> Terminal (Cmd+F12)**

```shell script
$ env up                               # start the container services
```

Run the 'local-dev' configuration in PyCharm.

> **PyCharm -> Run -> 'local-dev'**  
> _Launches: app, consumer, state, worker local_

Test the controller and verify functionality in your browser: http://localhost:9090/v1.0/ui  
_POST a new Flow to the controller using the swagger interface._

### Test Deployment

Create a test subscriber, and test the deployment in Kubernetes.

> **Pycharm -> View -> Windows -> Terminal (Cmd+F12)**

```shell script
$ sub-create                           # create a test subscriber
$ proxy                                # start the k8s proxy
$ deploy                               # deploy the microservice
$ url                                  # retrieve the controller URL
```

Test the controller using the swagger interface in your Browser.  
http://$REMOTE_IP:$NODEPORT/v1.0/ui  
_POST a new Flow to the controller using the swagger interface in your browser._

### Clone Project

Clone K-Lab to a new project and continue development.

> Pycharm -> Terminal

```shell script
$ ./env clone  <my_project>            # Clone k-lab example to a new project and continue development
```

## Vagrant VM

### Setup Vagrant VM

#### Native -> Terminal

$ git clone <k-lab_URL> # clone the project
$ cd k-lab/vagrant # change to vagrant directory
$ vagrant up # start the VM

#### Vagrant -> Terminal

$ cd code/k-lab # change k-lab directory
$ ./env prep -e http # setup venv and HTTP example, then reload term
$ charm . # open k-lab in PyCharm

... continue from 'Test Locally' from 'Native + PyCharm'

#### Contributors:

Click [Here](../-/graphs/master) to see who contributed to this project!

# k-lab

# k-lab
