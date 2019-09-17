# kube-prometheus

https://github.com/coreos/kube-prometheus#customizing-kube-prometheus

```bash
# get jb
curl -OL https://github.com/jsonnet-bundler/jsonnet-bundler/releases/download/v0.1.0/jb-linux-amd64
chmod u+x ./jb-linux-amd64
sudo mv ./jb-linux-amd64 /usr/local/bin/jb

# # from master
# sudo docker run -v $PWD:/go/bin golang:1.13 \
#   sh -c "go get github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb"
# sudo mv ./jb /usr/local/bin/

# get jsonnet
curl -L https://github.com/google/jsonnet/releases/download/v0.14.0/jsonnet-bin-v0.14.0-linux.tar.gz \
  | tar -zx
sudo mv jsonnet jsonnetfmt /usr/local/bin/

# get tanka
curl -fOL https://github.com/sh0rez/tanka/releases/download/v0.4.0/tk-linux-amd64
chmod u+x ./tk-linux-amd64
sudo mv ./tk-linux-amd64 /usr/local/bin/tk
```


```bash
# init
cd ./jsonnet
jb init
# jb install github.com/coreos/kube-prometheus/jsonnet/kube-prometheus@release-0.1
jb install github.com/coreos/kube-prometheus/jsonnet/kube-prometheus@26750eadf59279f409de47d616527a9632f8ab23

# update
# edit jsonnet/jsonnetfile.json
jb update
```

```bash

# render to verify
jsonnet --yaml-stream --jpath ./jsonnet/vendor ./main.jsonnet \
  > manifests-temp.json

# apply to cluster
jsonnet --yaml-stream --jpath ./jsonnet/vendor ./main.jsonnet \
  | kubectl apply -f -

# after changes at configmaps/secrets or volumeclaims
kubectl -n kube-prometheus rollout restart statefulset/prometheus-k8s

# logs
kubectl -n kube-prometheus logs prometheus-k8s-0 prometheus
kubectl -n kube-prometheus logs prometheus-k8s-1 prometheus
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

## FIXME
- add loki to prometheus sources