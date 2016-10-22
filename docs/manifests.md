# Manifests

## Ingress Controller

kubectl create namespace ingress
kubectl apply --filename ./manifests/ingress-controller-nginx


## Dashboard

```bash
kubectl apply --filename https://rawgit.com/kubernetes/dashboard/master/src/deploy/kubernetes-dashboard.yaml

# htpasswd -c auth admin
kubectl --namespace kube-system \
  create secret generic dashboard-basic-auth \
  --from-file=auth

kubectl apply --filename ./manifests/ingress/dashboard-ingress.yaml

# check
kubectl get --all-namespaces ingress --output wide
```

## Prometheus

```bash
kubectl create namespace monitoring
kubectl --namespace monitoring apply --filename ./manifests/prometheus

# htpasswd -c auth admin
kubectl --namespace monitoring \
  create secret generic prometheus-basic-auth \
  --from-file=auth

kubectl apply --filename ./manifests/ingress/prometheus-ingress.yaml

# check
kubectl get --all-namespaces ingress --output wide
```

## Grafana

```bash
# kubectl create namespace monitoring
kubectl --namespace monitoring apply --filename ./manifests/grafana

# htpasswd -c auth admin
kubectl --namespace monitoring \
  create secret generic grafana-basic-auth \
    --from-file=auth

kubectl apply --filename ./manifests/ingress/grafana-ingress.yaml

# check
kubectl get --all-namespaces ingress --output wide

```

## Slackin

```bash
kubectl create namespace slackin

echo -n "<slack-token>" > ./slack-token
kubectl --namespace slackin \
  create secret generic slackin \
    --from-file=slack-token

```
