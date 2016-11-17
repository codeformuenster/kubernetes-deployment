# Manifests

## Ingress Controller

kubectl apply --recursive --filename ./manifests/ingress-controller


# Node Affinity

kubectl label node 120fa67f-b5fe-4232-8c77-0c78e1c1c8ce.pub.cloud.scaleway.com \
  scaleway.com/name=kube0 \
  affinity/prometheus=true \
  affinity/grafana=true

kubectl label node 220d4345-ea09-4ba3-bf8e-bc2c86bc821c.pub.cloud.scaleway.com \
  scaleway.com/name=kube1 \
  affinity/elasticsearch=true

kubectl label node f6e5fcaf-35bf-424b-a2f9-900d3d1a9b11.pub.cloud.scaleway.com \
  scaleway.com/name=kube2

kubectl taint nodes --all dedicated-



## Monitoring

```bash
kubectl apply --recursive --filename ./manifests/monitoring


# htpasswd -c auth admin
kubectl --namespace kube-system \
  create secret generic dashboard-basic-auth \
  --from-file=auth

kubectl --namespace kube-system \
  create secret generic prometheus-basic-auth \
  --from-file=auth

kubectl --namespace kube-system \
  create secret generic grafana-basic-auth \
  --from-file=auth

kubectl --namespace kube-system \
  create secret generic elasticsearch-basic-auth \
  --from-file=auth


# check
kubectl get --all-namespaces ingress --output wide
```

## Slackin

```bash
kubectl apply --recursive --filename ./manifests/slackin

echo -n "<slack-token>" > ./slack-token
kubectl --namespace slackin \
  create secret generic slackin \
    --from-file=slack-token

```
