# cert-manager


```bash
# from upstream
rm ./base/cert-manager.yaml

curl -sfSL https://github.com/jetstack/cert-manager/releases/download/v0.8.1/cert-manager.yaml \
    -o ./base/cert-manager.yaml


# build manifests to verify
kustomize build ./overlay

# apply to cluster
kubectl create namespace cert-manager
kubectl apply -k ./overlay

# or place manifests in local directory
kustomize build ./overlay > ../../manifests/cert-manager/kustomized.yaml
kubectl apply -f ../../manifests/cert-manager

# or
kubectl apply --recursive -f ../../manifests
```
