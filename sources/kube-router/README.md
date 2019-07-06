# kube-router

https://github.com/cloudnativelabs/kube-router/releases

For features see https://github.com/cloudnativelabs/kube-router/blob/master/docs/user-guide.md#advertising-ips


```bash
# from upstream
rm ./base/kubeadm-kuberouter-all-features-hostport.yaml

curl -sfSL https://raw.githubusercontent.com/cloudnativelabs/kube-router/v0.3.1/daemonset/kubeadm-kuberouter-all-features-hostport.yaml \
    -o ./base/kubeadm-kuberouter-all-features-hostport.yaml


# build manifests to verify
kustomize build ./overlay

# apply to cluster
kubectl apply -k ./overlay

# or place manifests in local directory
rm ../../manifests/kube-router -rf && mkdir ../../manifests/kube-router
kubectl kustomize ./overlay > ../../manifests/kube-router/kustomized.yaml
kubectl apply -f ../../manifests/kube-router

# or
kubectl apply --recursive -f ../../manifests
```
