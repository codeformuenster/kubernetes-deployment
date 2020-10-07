
helm:
  https://github.com/nextcloud/helm/tree/master/charts/nextcloud


Idea for a Nextcloud operator:
- crd: https://lab.libreho.st/libre.sh/kubernetes/operators/nextcloud/blob/master/config/crd/bases/apps.libre.sh_nextclouds.yaml
- example: https://lab.libreho.st/libre.sh/kubernetes/operators/nextcloud/blob/master/config/samples/apps_v1alpha1_nextcloud.yaml


## kind test

https://kind.sigs.k8s.io/docs/user/ingress/

```bash
set -x KUBECONFIG "$HOME/.kube/config.d/temp-kind.config"
# kind create cluster

echo '
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
' | kind create cluster --config=-


# nginx-ingress
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/kind/deploy.yaml


kubectl create namespace nextcloud-test
kustomize build --enable_alpha_plugins . | kubectl apply -f -
```
