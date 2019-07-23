# Kustomized Kinto

```
kubectl kustomize ./overlay-cfm
```

## Kustomized Kinto for Verkehrsunfaelle


```
kubectl kustomize ./verkehrsunfaelle
```

---
```bash
kubectl kustomize ./overlay-shared > manifests-temp.yaml

kubectl create namespace shared-test
kubectl apply -k ./overlay-shared

```