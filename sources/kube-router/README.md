# kube-router

```bash
# build manifests to verify
kustomize build .

# apply to cluster
kubectl apply -k .
```

Maybe apply https://github.com/codeformuenster/kustomized/blob/master/kube-router/kube-proxy-cleanup.yaml, see https://github.com/cloudnativelabs/kube-router/blob/master/docs/kubeadm.md