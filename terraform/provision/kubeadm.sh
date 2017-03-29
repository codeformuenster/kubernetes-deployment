#!/usr/bin/env bash

node_num=$1
token=$2
master_ip_private=$3
master_ip_public=$4

echo "apiServerCertSANs: [\"$master_ip_public\"]" >> ./master-configuration.yaml
echo "token: $token" >> ./master-configuration.yaml

if [ "$node_num" = "0" ]; then
  kubeadm init --config master-configuration.yaml

  KUBECONFIG=/etc/kubernetes/admin.conf \
    kubectl apply --filename https://git.io/weave-kube-1.6
else
  kubeadm join --token $token $master_ip_private:6443
fi
