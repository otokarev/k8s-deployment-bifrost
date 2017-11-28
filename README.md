Kind of deployment automation for Bifrost

# Kubernates 
## Component Diagram
![Component Diagram](docs/images/k8s-bifrost.png)

## Prerequisites
* `Ansible` >= 2.4
* `google-cloud-sdk` installed, `gcloud` configured to have access the target project
* Create a service account with `Cloud SQL Client` role. Store json-file with private key localy (e.g. in `stellar-sql-client-key.json`)
* Get somewhere SSL certificate and certificate key and store them locally.
  
  Or use existing ones (for test purpose only!):
  * `files/certs/cert.crt`
  * `files/certs/cert.key`

## Configurations
Copy `group_vars/dev.sample` to `group_vars/dev`

Change it. Set appropriate settings.

**CAUTION:** Database in `stellar-core.cfg` must be configures as
```text
DATABASE="__DATABASE_URL__"`
```

## Deployment
Deploy the application (including SQL instance, cluster, etc)
```
ansible-playbook -i dev playbooks/deploy.yml 
```
It safe to run it several times. Failed Ansible tasks (e.g. be reason they were successfully processed before) will be skipped.



Remove the application, cluster, SQL instance, etc (DO NOT USE IT ON PRODUCTION)
```text
ansible-playbook -i dev playbooks/drop-all.yml 
```

## Maintenance

Run in console
```text
kubectl proxy
```

After that a web console available at `http://127.0.0.1:8001/ui` (choose right namespace to see something)

TODO

