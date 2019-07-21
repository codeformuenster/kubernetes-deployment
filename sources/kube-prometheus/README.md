# kube-prometheus

https://github.com/coreos/kube-prometheus#customizing-kube-prometheus

```bash
# get jb
sudo docker run -v $PWD:/go/bin golang:1.12 \
  sh -c "go get github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb"
sudo mv ./jb /usr/local/bin/

# get gojsontoyaml
sudo docker run -v $PWD:/go/bin golang:1.12 \
  sh -c "go get github.com/brancz/gojsontoyaml"
sudo mv ./gojsontoyaml /usr/local/bin/

# get jsonnet?
```

# or run via docker
https://github.com/coreos/kube-prometheus#containerized-installing-and-compiling

```bash
cd ./jsonnet
jb init
# jb install github.com/coreos/kube-prometheus/jsonnet/kube-prometheus@release-0.1

jb install github.com/coreos/kube-prometheus/jsonnet/kube-prometheus@16a49f00d6c77ad85abbfdba49e186808daf2764
jb update
```


## Apply to cluster

**FIXME**
- dont't create manifests locally but apply directly to the cluster
- show how to create locally for debugging purposes only

```bash
rm -r ../../manifests/kube-prometheus ; mkdir -p ../../manifests/kube-prometheus

jsonnet -J ./jsonnet/vendor -m ../../manifests/kube-prometheus main.jsonnet \
  | xargs -I{} sh -c 'cat {} | gojsontoyaml > {}.yaml; rm -f {}' -- {}

kubectl apply -f ../../manifests/kube-prometheus

# or
jsonnet --yaml-stream --jpath ./jsonnet/vendor ./main.jsonnet \
  > manifests-temp.json

kubectl apply -f ./manifests-temp.json

# or
jsonnet --yaml-stream --jpath ./jsonnet/vendor ./main.jsonnet \
  | kubectl apply -f -

# to pick up changes from configmaps/secrets
kubectl -n kube-prometheus rollout restart statefulset/prometheus-k8s
```

## more dashboards

https://github.com/coreos/kube-prometheus/blob/master/examples/grafana-additional-jsonnet-dashboard-example.jsonnet


## blackbox exporter

**FIXME** not yet done

https://github.com/coreos/prometheus-operator/issues/2010
https://github.com/coreos/prometheus-operator/tree/master/example/additional-scrape-configs


```bash
# FIXME
Linux: root user or CAP_NET_RAW capability is required.
    Can be set by executing setcap cap_net_raw+ep blackbox_exporter
```