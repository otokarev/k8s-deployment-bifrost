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
### Static IP
Create one for the service if not exists yet
```text
gcloud compute addresses create stellar-bifrost-static-ip --region=$REGION
```
Update `config.sh` with new value.

### PostgreSQL
```text
#Create intstance:
gcloud sql instances create $SQL_INSTANCE_ID \
    --no-backup \
    --database-version=POSTGRES_9_6 \
    --storage-type=HDD \
    --region=$REGION \
    --cpu=1 \
    --memory=3840MiB \
    --storage-auto-increase

#Create user:
gcloud sql users create stellar '*' --password=1q2w3e --instance=$SQL_INSTANCE_ID

#Create databases:
gcloud sql databases create core  --instance=$SQL_INSTANCE_ID
gcloud sql databases create horizon  --instance=$SQL_INSTANCE_ID
gcloud sql databases create bifrost  --instance=$SQL_INSTANCE_ID

```
Delete SQL instance:
```text
gcloud sql instances delete $SQL_INSTANCE_ID
```

### Cluster
Create cluster:
```text
gcloud container clusters create $CLUSTER_NAME \
    --no-enable-cloud-logging \
    --enable-cloud-monitoring \
    --no-enable-cloud-endpoints \
    --num-nodes=2 \
    --machine-type=n1-standard-2 \
    --zone=$ZONE
#Load cluster credentials:
gcloud container clusters get-credentials $CLUSTER_NAME --zone $ZONE --project $PROJECT
```
Delete cluster:
```text
gcloud container clusters delete $CLUSTER_NAME --zone=$ZONE
```
### Volumes
```text
gcloud compute disks create core-data --size 200GB --type pd-standard --zone $ZONE
gcloud compute disks create geth-data --size 200GB --type pd-standard --zone $ZONE
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
    
#Deploy Horizon Proxy SSL credentials and nginx config
kubectl create secret generic stellar-horizon-proxy-secret \
    --from-file=./volumes/horizon/certs/cert.crt \
    --from-file=./volumes/horizon/certs/cert.key \
    --from-file=./https-proxy.template
```
Delete secrets:
```text
kubectl delete secret --all
```
### Deployment
Deploy Stellar node application's pod:
```
envsubst < resources/service.yaml | kubectl create -f -
envsubst < resources/deployment.yaml | kubectl create -f -
```
###Maintenance
Pod cannot be launched if disk `core-data` is attached to any compute. To detach run in console:
```text
for i in `gcloud compute instances list | gawk 'NR>1 {print $1}'`; do gcloud compute instances detach-disk $i --zone $ZONE --disk=core-data; done
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
kubectl exec -it `kubectl get pods -o go-template="{{ (index .items 0).metadata.name }}"` -c core sh
```
Describe first pod from the list:
```text
kubectl describe  po/`kubectl get pods -o go-template="{{ (index .items 0).metadata.name }}"`
```
Get logs for `stellar-horizon`:
```text
kubectl logs `kubectl get pods -o go-template="{{ (index .items 0).metadata.name }}"` horizon -f
```
