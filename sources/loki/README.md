# loki

```bash
jsonnet --yaml-stream --jpath ./jsonnet/vendor ./main.jsonnet \
  > manifests-temp.json

kubectl apply -f ./manifests-temp.json

```



---

https://github.com/grafana/loki/tree/master/production/helm


```bash
# fetch
rm -r ./helm/loki ; mkdir -p ./helm/loki
helm fetch \
  --repo https://grafana.github.io/loki/charts \
  --untar \
  --untardir ./helm \
    loki-stack

# create base for kustomize
rm -r ./base/loki ; mkdir -p ./base/loki

helm template \
  --name loki \
  --namespace loki \
  --values ./helm/values.yaml \
  --output-dir ./base \
  ./helm/loki-stack


# run kustomize
rm -r ../../manifests/loki ; mkdir -p ../../manifests/loki
kubectl kustomize ./overlay > ../../manifests/loki/kustomized.yaml

kubectl create namespace loki
kubectl apply -f ../../manifests/loki

# after config changes for promtail maybe run
kubectl -n loki delete pods -l app=promtail
```

In Grafana add Datasource Loki with `http://loki.loki:3100`

Also see https://github.com/grafana/loki/blob/master/docs/logcli.md


## Also

- https://grafana.com/blog/2019/01/02/closer-look-at-grafanas-user-interface-for-loki/
- https://github.com/grafana/loki/tree/master/fluentd/fluent-plugin-grafana-loki
- Add Jaeger for tracing