# ingress-nginx

*FIXME*
- Use json for logs https://github.com/kubernetes/ingress-nginx/blob/master/docs/user-guide/nginx-configuration/configmap.md#log-format-upstream
    - Adjust Loki
    - create metrics for TLS versions that connect, see next
- Add TLSv3 https://github.com/kubernetes/ingress-nginx/blob/master/docs/user-guide/nginx-configuration/configmap.md#ssl-protocols
- maybe use-proxy-protocol? https://github.com/kubernetes/ingress-nginx/blob/master/docs/user-guide/nginx-configuration/configmap.md#use-proxy-protocol
- use-geoip2?

https://github.com/kubernetes/ingress-nginx/pull/4055
and https://kubectl.docs.kubernetes.io/pages/app_management/secrets_and_configmaps.html
check:
```yaml
configMapGenerator:
- name: nginx-configuration
  behavior: merge
  literals:
  - use-http2="false"
  - ssl-protocols="TLSv1 TLSv1.1 TLSv1.2"
  - worker-shutdown-timeout="13s"
  # etc
```
also in general:
```yaml
# kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
configMapGenerator:
- name: my-application-properties
  files:
  - application.properties
```


```bash
# refresh from upstream
rm -r ./base ; mkdir -p ./base

curl -L https://github.com/kubernetes/ingress-nginx/archive/master.tar.gz \
    | tar -xz --directory ./base --strip-components=2 \
        ingress-nginx-master/deploy/cloud-generic \
        ingress-nginx-master/deploy/cluster-wide \
        ingress-nginx-master/deploy/grafana/dashboards

# place manifests in local directory
rm -r ../../manifests/ingress-nginx ; mkdir -p ../../manifests/ingress-nginx
kubectl kustomize ./overlay > ../../manifests/ingress-nginx/kustomized.yaml

kubectl create namespace ingress-nginx
kubectl apply -f ../../manifests/ingress-nginx

```

In Grafana import dashboard https://grafana.com/dashboards/9614
