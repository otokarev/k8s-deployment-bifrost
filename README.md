Bifrost deployment
==================
Kind of deployment automation for Bifrost

Prerequisites
-------------
BEWARE: in this repo git-submodules are used!

Development environment
-----------------------
Files:
* `Vagrantfile`, `playbook.yml` if you cannot run `docker` and `docker-compose` locally or have some troubles installing these services you can launch Docker-aware environment as

BEWARE: virtual box storage is only 10G, resize it to 15G as described here (http://tuhrig.de/resizing-vagrant-box-disk-space/, https://tech.enekochan.com/en/2014/09/17/fix-vboxmanage-error-cannot-register-the-hard-disk-because-a-hard-disk-already-exists/)

Run:
```text
vagrant up
```

Docker Compose based deployment
-------------------------------
Files:
* `docker-compose.yaml` is a playbook to deploy bifrost related Docker containers through `docker-compose`

Run
```text
cd /vagrant/
docker-compose up
```