# Digitrans

see:
- https://digitransit.fi/en/
- https://github.com/verschwoerhaus/digitransit-kubernetes
- https://digitransit.fi/en/services/

- https://github.com/HSLdevcom/digitransit-kubernetes-deploy/blob/master/roles/aks-apply/files/prod/graphiql-prod.yml

```bash
kubectl create namespace digitransit
kustomize build . | kubectl apply -f -
```

## Configuring Realtime

http://docs.opentripplanner.org/en/latest/Configuration/#real-time-data

