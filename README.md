# Bifrost deployment

Kind of deployment automation for Bifrost

## Docker Compose prototype
### Prerequisites

**BEWARE**: in this repo [git-submodules](https://github.com/blog/2104-working-with-submodules) are used!

Initial checkout:
```text
git clone --recursive git@github.com:otokarev/k8s-deployment-bifrost.git
```

or run after `git clone` from project folder:
```text
git submodule update --init --recursive
```

### Test Environment for workstation

The project is supplied with Vagrantfile/playbook.yml (VirtualBox/Ansible/Vagrant required) to install isolated virtual server to test Docker Compose deployment inside of it.

```text
vagrant up

```
**BEWARE:** virtual box storage is only 10G, resize it to 30G as described here (http://tuhrig.de/resizing-vagrant-box-disk-space/, https://tech.enekochan.com/en/2014/09/17/fix-vboxmanage-error-cannot-register-the-hard-disk-because-a-hard-disk-already-exists/)

### Docker Compose based deployment

![Dependencies Graph](docs/images/dependencies-graph.png)

**Services**
* **bifrost-app** WEB UI Node.js app designed to demonstrate Bifrost main use-case
* **bifrost** Main Bifrost daemon
* **geth** Geth - Ethereum node
* **geth-data** - the place eth node stores its data
* **bifrost-init** - the service initializing Bifrost DB 
* **bifrost-db** - Bitfrost DB
* **horizon** - Stellar Horizon server
* **horizon-proxy** - Stellar Horizon behind HTTPS (nginx)
* **horizon-init** - the service initializing Horizon DB
* **horizon-db** - Horizon DB
* **core** - Stellar Core server
* **core-data** - Stellar Core data volume
* **core-db** - Stellar Core DB

Files:
* `docker-compose.yaml` is a playbook to deploy bifrost related Docker containers through `docker-compose`

Run from project folder or `/vagrant` if the mentioned above vagrant box was installed
```text
docker-compose up
```
## Kubernates 
TODO
