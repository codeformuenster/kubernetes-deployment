# keycloak

```bash
# check manifests
kubectl kustomize .

# push to cluster
kubectl apply -k .
```


## FIXME
- create of fetch secret from file on keybasefs
    https://github.com/kubernetes-sigs/kustomize/blob/master/examples/secretGeneratorPlugin.md#secret-values-from-anywhere
