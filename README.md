Kind of deployment automation for Bifrost

# Kubernates 
## Credentials
Create a service account with `Cloud SQL Client` role. Store json-file with private key localy (e.g. in `stellar-sql-client-key.json`)

Update SSL certificate and certificate key stored as:
* `files/certs/cert.crt`
* `files/certs/cert.key`

or use existing ones (for test purpose only!)
## Configurations
```text
cd ansible
cp host_vars/localhost.sample host_vars/localhost
```

Minimal `host_vars/localhost` update to be able run playbook:

* `stellar_core_image` must refer to image based on - https://github.com/otokarev/docker-stellar-core
* `stellar_horizon_image` must refer to image based on - https://github.com/otokarev/docker-stellar-horizon
* `stellar_bifrost_image` must refer to image based on - https://github.com/otokarev/docker-stellar-bifrost
* `stellar_bifrost_client_image` must refer to image based on - https://github.com/otokarev/docker-stellar-bifrost-client

* `project` your existing project ID

* `sql_instance_id` instance ID for *new* SQL instance, make sure it will not collide with other instance's ID


## Deployment
Deploy the application (including SQL instance, cluster, etc)
```
cd ansible
ansible-playbook -i localhost deploy.yml
```
Remove the application, cluster, SQL instance
```text
cd ansible
ansible-playbook -i localhost deploy.yml
```

##Maintenance
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

Delete all PVs with label `service` equal to `geth`
```text
kubectl get pv -l 'service=geth' -o go-template='{{range .items }}{{.metadata.name}} {{end}}' | xargs kubectl delete pv
```
