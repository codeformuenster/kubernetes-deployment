# ingress-nginx

```bash
# refresh from upstream
rm -r ./base ; mkdir -p ./base

curl -L https://github.com/kubernetes/ingress-nginx/archive/master.tar.gz \
    | tar -xz --directory ./base --strip-components=2 \
        ingress-nginx-master/deploy/cloud-generic \
        ingress-nginx-master/deploy/cluster-wide \
        ingress-nginx-master/deploy/grafana/dashboards

# build manifests to verify
kustomize build .

# apply to cluster
kubectl create namespace ingress-nginx
kubectl apply -k ./base

# or place manifests in local directory
rm -r ../../manifests/ingress-nginx ; mkdir -p ../../manifests/ingress-nginx

kustomize build ./base > ../../manifests/ingress-nginx/kustomized.yaml
kubectl apply --recursive -f ../../manifests/ingress-nginx/kustomized.yaml

# or
kubectl apply --recursive -f ../../manifests
```
