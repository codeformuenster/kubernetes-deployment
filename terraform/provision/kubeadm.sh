#!/usr/bin/env bash

node_num=$1
token=$2
master_ip=$3

cd /root/provision

echo "token: $token" >> ./master-configuration.yaml


apt update
apt -y install apt-transport-https

curl https://packages.cloud.google.com/apt/doc/apt-key.gpg \
  | apt-key add -

echo 'deb http://apt.kubernetes.io/ kubernetes-xenial-unstable main' \
  > /etc/apt/sources.list.d/kubernetes.list

apt update
# apt -y install docker-engine kubeadm kubelet kubernetes-cni kubectl
apt -y install docker.io kubeadm kubelet kubernetes-cni kubectl


for service in kubeadm kubelet
do
  curl -Lo /usr/local/bin/$service https://dl.k8s.io/v1.6.0-rc.1/bin/linux/amd64/$service
  chmod +x /usr/local/bin/$service
done

# for elasticsearch
# https://www.elastic.co/guide/en/elasticsearch/reference/current/system-config.html
echo "* - nofile 65536" > /etc/security/limits.d/elasticsearch
echo "vm.max_map_count = 262144" > /etc/sysctl.d/elasticsearch


if [ "$node_num" = "0" ]; then
  kubeadm init --config master-configuration.yaml

  KUBECONFIG=/etc/kubernetes/admin.conf \
    kubectl apply --filename https://git.io/weave-kube-1.6
else
  kubeadm join --token $token $master_ip:6443
fi
