# ingress-nginx

FIXME add prometheus-servicemonitor

```bash
# refresh from upstream
rm -r ./base ; mkdir -p ./base

curl -L https://github.com/kubernetes/ingress-nginx/archive/master.tar.gz \
    | tar -xz --directory ./base --strip-components=2 \
        ingress-nginx-master/deploy/cloud-generic \
        ingress-nginx-master/deploy/cluster-wide \
        ingress-nginx-master/deploy/grafana/dashboards

# build manifests to verify
kubectl kustomize ./overlay

# apply to cluster
kubectl create namespace ingress-nginx
kubectl apply -k ./overlay

# or place manifests in local directory
rm -r ../../manifests/ingress-nginx ; mkdir -p ../../manifests/ingress-nginx

kubectl kustomize ./overlay > ../../manifests/ingress-nginx/kustomized.yaml
kubectl apply -f ../../manifests/ingress-nginx

# or
kubectl apply --recursive -f ../../manifests
```
