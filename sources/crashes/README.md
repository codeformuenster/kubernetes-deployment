# crashes

```bash
# build manifests to verify
kustomize build .

# apply to cluster
kubectl create namespace crashes
kustomize build . | kubectl apply -f -
```
