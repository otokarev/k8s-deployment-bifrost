Bifrost deployment
==================
Kind of deployment automation for Bifrost

Prerequisites
-------------
BEWARE: in this repo git-submodules are used!

Files & Directories
-------------------
* `Vagrantfile`, `playbook.yml` if you cannot run `docker` and `docker-compose` locally or have some troubles installing these services you can launch Docker-aware environment as
```text
vagrant up
```
* `docker-compose.yaml` is a playbook to deploy bifrost related Docker containers through `docker-compose`
```text
docker-compose up
```