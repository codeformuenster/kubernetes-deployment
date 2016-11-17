work in progress, proof of concept.
Mostly `fish` shell.

<!-- FIXME show "organization/token" used on every run? -->

# Scaleway CLI

## install

```bash
curl -SL https://github.com/scaleway/scaleway-cli/releases/download/v1.11/scw_1.11_linux_amd64.tar.gz \
  | tar -xzf -
sudo mv ./scw_1.11_linux_amd64/scw /usr/local/bin/
scw version
```

## scw login

```bash
scw login --skip-ssh-key
scw info
scw ps --all
```

## create servers

FIXME read in json/yaml and loop over

```bash
scw create \
  --name kube0 \
  --commercial-type VC1M \
  --ip-address 163.172.158.84 \
  --volume 50G \
  --env "kubeadm master" \
  Ubuntu_Xenial

scw create \
  --name kube1 \
  --commercial-type VC1M \
  --ip-address 212.47.232.30 \
  --volume 50G \
  --env "kubeadm worker" \
  Ubuntu_Xenial

scw create \
  --name kube2 \
  --commercial-type VC1M \
  --volume 50G \
  --env "kubeadm worker" \
  Ubuntu_Xenial
```

## on all nodes

FIXME optimization: run parallel

FIXME
> A new version (/etc/apt/apt.conf.d/50unattended-upgrades.ucftmp) of configuration file /etc/apt/apt.conf.d/50unattended-upgrades is available, but the version installed currently has been locally modified.

FIXME don't ask on apt install

```bash
scw ps --all --filter "tags=kubeadm" --quiet | xargs echo -n | read --array server_ids
for server in (scw inspect $server_ids | jq -c '.[]')

  set server_id (echo $server | jq -r '.id')

  scw start $server_id
  scw exec --wait $server_id \
    echo '$(hostname) is ready'

  scw cp ./scripts/kubeadm "$server_id:/root"
  scw exec --wait $server_id \
    /root/kubeadm/prepare-node.sh $server_id
  # scw exec --wait $server_id \
  #   rm /etc/kubernetes/pki -rf

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

scw exec --wait $server_id \
  /root/kubeadm/master-init.sh $server_ip_pub

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
./scripts/kubectl/fetch-credetials.fish cfm
kubectl config use-context cfm
```


## check
```bash
kubectl get nodes
```
