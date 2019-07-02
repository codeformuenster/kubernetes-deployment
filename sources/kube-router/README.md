# kube-router

https://github.com/cloudnativelabs/kube-router/releases

For features see https://github.com/cloudnativelabs/kube-router/blob/master/docs/user-guide.md#advertising-ips

**FIXME**
- use tag with docker-image

```bash
# from upstream
rm ./base/kubeadm-kuberouter-all-features-hostport.yaml

curl -sfSL https://raw.githubusercontent.com/cloudnativelabs/kube-router/v0.3.1/daemonset/kubeadm-kuberouter-all-features-hostport.yaml \
    -o ./base/kubeadm-kuberouter-all-features-hostport.yaml


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
