# swms-busradar-gtfs-realtime Deployment

Deployment of [swms-busradar-gtfs-realtime](https://github.com/codeformuenster/swms-busradar-gtfs-realtime)

```bash
# build manifests to verify
kubectl kustomize

# apply to cluster
kubectl create namespace swms-busradar-gtfs-realtime
kubectl apply -k .
```
