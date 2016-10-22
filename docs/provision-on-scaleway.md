work in progress, proof of concept.
Mostly `fish` shell.

# Scaleway CLI

## build scaleway-cli from HEAD

Current release of scaleway-cli is [buggy](https://github.com/scaleway/scaleway-cli/issues/395). Build from master: 

```bash
docker run --rm -ti \
  --volume $PWD/_out:/go/bin \
  golang:1.7 \
    bash -c "go get -d github.com/scaleway/scaleway-cli/... && cd /go/src/github.com/scaleway/scaleway-cli && make && cp scw /go/bin"

_out/scw version
sudo cp _out/scw /usr/local/bin/
```


## scw login

scw login \
  --skip-ssh-key

scw info

scw ps --all


## create servers

Fri Oct 21 18:59:20 CEST 2016

```bash
scw create \
  --name kube01 \
  --commercial-type VC1M \
  --ip-address 163.172.158.84 \
  --volume 50G \
  --env "kubeadm master" \
  Ubuntu_Xenial

scw create \
  --name kube02 \
  --commercial-type VC1M \
  --ip-address 212.47.232.30 \
  --volume 50G \
  --env "kubeadm worker" \
  Ubuntu_Xenial

scw create \
  --name kube03 \
  --commercial-type VC1M \
  --volume 50G \
  --env "kubeadm worker" \
  Ubuntu_Xenial



# on all nodes
# optimization: run parallel
scw ps --all --filter "tags=kubeadm" --quiet | xargs echo -n | read --array server_ids
for server in (scw inspect $server_ids | jq -c '.[]')

  set server_id (echo $server | jq -r '.id')

  scw start $server_id
  scw exec --wait $server_id \
    echo '$(hostname) is ready'

  scw cp ./scripts/kubeadm/prepare-node.sh "$server_id:/root"
  scw exec --wait $server_id \
    /root/prepare-node.sh $server_id

  scw exec --wait $server_id \
    echo '$(hostname) is ready'

end
```


## master

```bash
scw ps --all --filter "tags=master" --quiet | xargs echo -n | read --array server_ids
# only one master server for now
set server_id $server_ids[1]
# server_ip_pub
set server_ip_pub (scw inspect $server_id | jq -r  '.[] | .public_ip.address')

printf "\
kubeadm init --api-advertise-addresses $server_ip_pub
kubectl apply --filename https://git.io/weave-kube
" | scw exec --wait $server_id

# kubectl taint nodes --all dedicated-
```

## worker

```bash
scw ps --all --filter "tags=master" --quiet | xargs echo -n | read --array server_ids
# master_ip
set master_ip (scw inspect $server_ids[1] | jq -r  '.[] | .private_ip')
# token, retry?
scw exec --wait $server_ids[1] kubectl --namespace kube-system get secret clusterinfo -o json | jq -r '.data."token-map.json"' | base64 --decode | tr ":" "." | tr -d "{\"}" | read token

# all workers
scw ps --all --filter "tags=worker" --quiet | xargs echo -n | read --array server_ids
for server_id in $server_ids
  scw exec --wait $server_id \
    kubeadm join --token $token $master_ip
end
```


## remote

```bash
# FIXME refactor script
./scripts/kubectl/fetch-credetials.fish kube01 cfm
kubectl config use-context cfm
```


kubectl get nodes
NAME                                                           STATUS    AGE
38f1aae0-69ae-4994-984d-92669086cb2c.priv.cloud.scaleway.com   Ready     4m
3f610664-66f1-4219-a6f1-9105f4001fa7.priv.cloud.scaleway.com   Ready     1m
8b693d4e-0185-4419-8cfd-232daf237c91.priv.cloud.scaleway.com   Ready     1m

Fri Oct 21 19:25:19 CEST 2016






## scaleway-cli

see:
  - https://github.com/scaleway/scaleway-cli
  - https://github.com/scaleway/scaleway-cli/releases

curl --location https://github.com/scaleway/scaleway-cli/releases/download/v1.9.0/scw_1.9.0_linux_amd64.tar.gz \
  | tar --extract -z --directory /tmp scw_1.9.0_linux_amd64/scw
sudo mv /tmp/scw_1.9.0_linux_amd64/scw /usr/local/bin
rmdir /tmp/scw_1.9.0_linux_amd64
