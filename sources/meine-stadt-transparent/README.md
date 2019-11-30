# Meine Stadt Transparent

Kubernetes deployment for [https://github.com/meine-stadt-transparent/meine-stadt-transparent](https://github.com/meine-stadt-transparent/meine-stadt-transparent)

## Instructions

- Use the `secrets/*.env-example` files to create service secrets in the `secrets` folder. Fill your newly created files with random strings
- Install [`certstrap`](https://github.com/square/certstrap/releases/tag/v1.2.0)
- Generate certificates for elasticsearch with the script `make-elasticsearch-certs.sh`


Then:

```bash
kubectl create namespace meine-stadt-transparent
kustomize build . | kubectl apply -f -
```
