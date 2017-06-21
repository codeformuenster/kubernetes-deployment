# Kubernetes Cluster on Scaleway

> experimental! may destroy all your things! please fix me!

Lookup credentials of your Scaleway account: https://cloud.scaleway.com/#/credentials

Edit `scaleway-config.tfvars`, see `main.tf` for defaults.


If you want to log to a file:
```bash
export TF_LOG="WARN" # TRACE, DEBUG, INFO, WARN or ERROR
export TF_LOG_PATH="terraform.log"
```

Applying your configuration. IMPORTANT! Might destroy existing stuff!
```bash
terraform apply \
  -var-file=scaleway-config.tfvars
```

When you want to start from scratch, delete terraforms state files:
```bash
rm terraform.state
```

## Execution Graph

![Visual execution graph of Terraform resources](terraform.png?raw=true)


## On the Cluster

```
KUBECONFIG=/etc/kubernetes/admin.conf kubectl help
```

Remote
```
scp root@$master:/etc/kubernetes/admin.conf .

curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x kubectl

./kubectl --kubeconfig ./admin.conf get nodes
./kubectl --kubeconfig ./admin.conf get --all-namespaces pods
```
