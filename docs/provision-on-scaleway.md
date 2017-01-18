work in progress, proof of concept.
Mostly `fish` shell.

<!-- FIXME show "organization/token" used on every run? -->

# Scaleway CLI

## install

```bash
curl -SL https://github.com/scaleway/scaleway-cli/releases/download/v1.11.1/scw_1.11.1_linux_amd64.tar.gz \
  | tar -xzf -
sudo mv ./scw_1.11.1_linux_amd64/scw /usr/local/bin/
scw version
```
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

scw --region="ams1"

    "kernel": "http://169.254.42.24/kernel/x86_64-4.8.14-std-2/vmlinuz-4.8.14-std-2",
    "id": "f26ba64e-e01b-4b69-8ad3-61e56a32d7ed",


```bash
scw create \
  --commercial-type VC1M \
  --bootscript 4.8.14-std \
  --ip-address 163.172.162.231 \
  --volume 50G \
  --env "kubeadm master" \
  Ubuntu_Xenial

scw create \
  --name kube1 \
  --commercial-type VC1M \
  --volume 50G \
  --env "kubeadm worker" \
  Ubuntu_Xenial



scw create \
  --commercial-type VC1M \
  --bootscript 4.8.14-std-2 \
  --volume 50G \
  xenial

kubeadm join --token=4e9d31.1bd662ac3dbe9060 163.172.158.84




```

## on all nodes

FIXME optimization: run parallel

FIXME
> A new version (/etc/apt/apt.conf.d/50unattended-upgrades.ucftmp) of configuration file /etc/apt/apt.conf.d/50unattended-upgrades is available, but the version installed currently has been locally modified.

FIXME don't ask on apt install

```bash
scw ps --all --filter "tags=kubeadm" --quiet | xargs echo -n | read --array server_ids
printf "%s\n" $server_ids
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
./scripts/kubectl/fetch-credetials.fish thisone
kubectl config use-context thisone
```


## check
```bash
kubectl config current-context
kubectl get nodes
```
