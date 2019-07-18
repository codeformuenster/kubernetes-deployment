# cert-manager


```bash
# from upstream
rm ./base/cert-manager.yaml

curl -sfSL https://github.com/jetstack/cert-manager/releases/download/v0.8.1/cert-manager.yaml \
    -o ./base/cert-manager.yaml

# remove RoleBinding cert-manager-webhook:webhook-authentication-reader
# because of kustomization problem with multiple namespaces.
# apply that separately

# build manifests to verify
kubectl kustomize ./overlay

# apply to cluster
# namespace needs special label
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: cert-manager
  labels:
    certmanager.k8s.io/disable-validation: "true"
EOF
kubectl apply -f ./webhook-rolebinding.yaml
kubectl apply -k ./overlay

```
