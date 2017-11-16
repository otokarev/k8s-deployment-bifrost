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
### Configurations
Copy `./config.template.sh` to `config.sh` and give values to all variables listed there

Run:
```text
source ./config.sh
```

After that config settings can be used in commands mentioned below.

Code like
```text
envsubst < resource.yaml | command
```
will read `resource.yaml`, substitute environment variables that we have just set and pass the result to the pipe.

### Cluster
Create cluster:
```text
gcloud container clusters create stellar-bifrost \
    --no-enable-cloud-logging \
    --enable-cloud-monitoring \
    --no-enable-cloud-endpoints \
    --num-nodes=2 \
    --machine-type=n1-standard-2 \
    --zone=europe-west1-d
```
Load cluster credentials:
```text
gcloud container clusters get-credentials stellar-bifrost --zone europe-west1-d --project lucid-course-142515
```
Delete cluster:
```text
gcloud container clusters delete stellar-bifrost
```
### Volumes
```text
gcloud compute disks create core-data --size 200GB --type pd-standard --zone europe-west1-d
gcloud compute disks create geth-data --size 200GB --type pd-standard --zone europe-west1-d
```

### Secrets
Create a service account with `Cloud SQL Client` role. Store json-file with private key localy (e.g. in `stellar-sql-client-key.json`)

```text
# Deploy database client credentials:
kubectl create secret generic cloudsql-instance-credentials --from-file=credentials.json=./stellar-sql-client-key.json

# Stellar Core configuration file:
kubectl create secret generic stellar-core-cfg --from-file=stellar-core.cfg=./volumes/core/configs/stellar-core.cfg

#Deploy database credentials secret:
kubectl create secret generic stellar-database-credentials \
    --from-literal=STELLAR_CORE_DATABASE_URL="${STELLAR_CORE_DATABASE_URL}" \
    --from-literal=STELLAR_HORIZON_DATABASE_URL="${STELLAR_HORIZON_DATABASE_URL}" \

#Deploy bifrost credentials
kubectl create secret generic stellar-bifrost-credentials \
    --from-literal=STELLAR_BIFROST_CFG="${STELLAR_BIFROST_CFG}" \
    --from-literal=STELLAR_BIFROST_DATABASE_URL="${STELLAR_BIFROST_DATABASE_URL}"
```
### Deployment
Deploy Stellar node application's pod:
```
envsubst < resources/deployment.yaml | kubectl create -f -
```
###Maintenance
Pod cannot be launched if disk `core-data` is attached to any compute. To detach run in console:
```text
for i in `gcloud compute instances list | gawk 'NR>1 {print $1}'`; do gcloud compute instances detach-disk $i --zone europe-west1-d --disk=core-data; done
```

To modify the deployment:
```
kubectl edit deployment/stellar --save-config
```
To see logs (stellar core):
```
kubectl log deployment/stellar -c core -f
```
To see logs (stellar horizon):
```
kubectl log deployment/stellar -c horizon -f
```
Delete the deployment:
```text
kubectl delete deployment stellar
```
Delete the service:
```text
kubectl delete service stellar
```
Launch bash in Stellar core container:
```text
kubectl exec -it <pod name something like stellar-885092335-xc8sr, can be found in `kubectl get pods` output> -c core /bin/bash
```
Describe first pod from the list:
```text
kubectl describe  po/`kubectl get pods -o go-template="{{ (index .items 0).metadata.name }}"`
```
Get logs for `stellar-horizon`:
```text
kubectl logs `kubectl get pods -o go-template="{{ (index .items 0).metadata.name }}"` horizon -f
```
