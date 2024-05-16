# Deployment on Kubernetes

License: [MIT](LICENSE)

## Old master

Old master branch has been preserved in [`old-master`](https://github.com/codeformuenster/kubernetes-deployment/tree/old-master) branch.

## Encrypted secrets

Secrets in this repository should be encrypted using [SOPS](https://github.com/mozilla/sops) and [age](https://github.com/FiloSottile/age).

```
# decrypt
SOPS_AGE_KEY_FILE=/path/to/your/key.txt sops --output path/to/file --decrypt path/to/sops-secret.file

# edit ...

# encrypt again (public age key comes from the .sops.yaml)
sops --output path/to/sops-secret.file -e path/to/file
```
