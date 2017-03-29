# Kubernetes Cluster on Scaleway

> experimental! may destroy all your things! please fix me!

Edit `scaleway-config.tfvars`, see `main.tf` for defaults.

Lookup credentials of your Scaleway account: https://cloud.scaleway.com/#/credentials
```bash
export SCALEWAY_ORGANIZATION "{ access key }"
export SCALEWAY_TOKEN "{ token }"
```

If you want to log to a file:
```bash
export TF_LOG="INFO" # TRACE, DEBUG, INFO, WARN or ERROR
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
