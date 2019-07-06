# openebs

https://docs.openebs.io/docs/overview.html


## setup

```bash
# from upstream
curl -sfSL https://openebs.github.io/charts/openebs-operator-1.0.0.yaml \
    -o ./base/openebs-operator.yaml

# place manifests in local directory
rm ../../manifests/openebs -rf && mkdir ../../manifests/openebs
kubectl kustomize ./overlay > ../../manifests/openebs/kustomized.yaml

# verify created manifests, then
kubectl apply -f ../../manifests/openebs

# create storagepool: edit cstor-storage.yaml
# cstor-disk-pool > spec.blockDevices.blockDeviceList
kubectl apply -f ./cstor-storage.yaml

```


## debug

```bash
kubectl api-resources --api-group openebs.io

kubectl -n openebs logs -f -l openebs.io/component-name=ndm-operator
kubectl -n openebs logs -f -l openebs.io/component-name=maya-apiserver

kubectl get --all-namespaces blockdevices

kubectl api-resources --api-group openebs.io -o name \
  | xargs -n 1 kubectl get --all-namespaces --show-kind --ignore-not-found

kubectl get storageclasses
kubectl get storagepoolclaim.openebs.io
kubectl get cstorpools
```


## deleting

```bash
# before deleting uncomment namespace in manifest
kubectl delete -f ../../manifests/openebs

kubectl get storageclasses -o name | fgrep "openebs-" \
  | xargs -n 1 kubectl delete

kubectl api-resources --api-group openebs.io -o name \
  | xargs -n 1 kubectl delete --all-namespaces --all

kubectl api-resources --api-group openebs.io -o name \
  | xargs -n 1 kubectl delete crd

kubectl delete ValidatingWebhookConfiguration validation-webhook-cfg
kubectl delete namespace openebs

# when stuck
kubectl proxy

kubectl get namespace openebs -o json \
  | jq 'del(.spec.finalizers[] | select("kubernetes"))' \
  | curl --request PUT --header "Content-Type: application/json" \
    --data-binary @- http://localhost:8001/api/v1/namespaces/openebs/finalize
```


## FIXME

- disable localpv
