# nominatim

```bash
# build manifests to verify
kustomize build ./overlay

# apply to cluster
kubectl create namespace nominatim
kubectl apply -k ./overlay

# or place manifests in local directory
rm -r ../../manifests/nominatim ; mkdir -p ../../manifests/nominatim

kubectl kustomize ./overlay > ../../manifests/nominatim/kustomized.yaml
kubectl apply -f ../../manifests/nominatim/kustomized.yaml

# or
kubectl apply --recursive -f ../../manifests
```
