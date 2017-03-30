#!/usr/bin/env bash

node_num=$1
token=$2
master_ip_private=$3
master_ip_public=$4

echo "apiServerCertSANs: [\"$master_ip_public\"]" >> ./master-configuration.yaml
echo "token: $token" >> ./master-configuration.yaml

if [ "$node_num" = "0" ]; then

  cp 10-kubeadm-hack.conf /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
  systemctl daemon-reload
  systemctl restart kubelet

  kubeadm init --config master-configuration.yaml

  cp 10-kubeadm.conf /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
  systemctl daemon-reload
  systemctl restart kubelet

  KUBECONFIG=/etc/kubernetes/admin.conf \
    kubectl apply --filename https://git.io/weave-kube-1.6
else
  kubeadm join --token $token $master_ip_private:6443
fi
