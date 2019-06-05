# ingress-nginx

```bash
# refresh from upstream
rm -r ./upstream ; mkdir -p ./upstream

curl -L https://github.com/kubernetes/ingress-nginx/archive/master.tar.gz \
    | tar -xz --directory ./upstream --strip-components=2 \
        ingress-nginx-master/deploy/cloud-generic \
        ingress-nginx-master/deploy/cluster-wide \
        ingress-nginx-master/deploy/grafana/dashboards

# build manifests to verify
kustomize build .

# apply to cluster
kubectl create namespace ingress-nginx
kubectl apply -k .

# or place manifests in local directory
rm -r ../../manifests/ingress-nginx ; mkdir -p ../../manifests/ingress-nginx

kustomize build . > ../../manifests/ingress-nginx/kustomized.yaml
kubectl apply --recursive -f ../../manifests/ingress-nginx/kustomized.yaml

# or
kubectl apply --recursive -f ../../manifests
```
