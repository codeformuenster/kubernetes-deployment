# kube-prometheus

```bash
# refresh from upstream
rm -r ./base ; mkdir -p ./base

curl -L https://github.com/coreos/kube-prometheus/archive/master.tar.gz \
    | tar -xz --directory ./base --strip-components=1 \
        kube-prometheus-master/kustomization.yaml \
        kube-prometheus-master/manifests

# namespace will be overriden by kustomize but should rather stay as `kube-system`
mv ./base/manifests/prometheus-adapter-roleBindingAuthReader.yaml .
touch ./base/manifests/prometheus-adapter-roleBindingAuthReader.yaml

# build manifests to verify
kustomize build .


# place manifests in local directory
rm -r ../../manifests/kube-prometheus ; mkdir -p ../../manifests/kube-prometheus

kustomize build . > ../../manifests/kube-prometheus/kustomized.yaml
cp ./prometheus-adapter-roleBindingAuthReader.yaml ../../manifests/kube-prometheus

# apply to cluster
kubectl create namespace kube-prometheus
kubectl apply -f ../../manifests/kube-prometheus

# or
kubectl apply --recursive -f ../../manifests
```


kubectl create rolebinding -n kube-system ROLE_NAME --role=extension-apiserver-authentication-reader --serviceaccount=YOUR_NS:YOUR_SA

unable to install resource metrics API: configmaps "extension-apiserver-authentication" is forbidden:

User "system:serviceaccount:kube-prometheus:prometheus-adapter" cannot get resource "configmaps" in API group "" in the namespace "kube-system"
