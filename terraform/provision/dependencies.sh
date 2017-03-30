#!/usr/bin/env bash

apt update
apt -y install apt-transport-https

curl https://packages.cloud.google.com/apt/doc/apt-key.gpg \
  | apt-key add -

# echo 'deb http://apt.kubernetes.io/ kubernetes-xenial-unstable main' \
echo 'deb http://apt.kubernetes.io/ kubernetes-xenial main' \
  > /etc/apt/sources.list.d/kubernetes.list

apt update
# apt -y install docker-engine kubeadm kubelet kubernetes-cni kubectl
apt -y install docker.io kubeadm kubelet kubernetes-cni kubectl

# for elasticsearch
# https://www.elastic.co/guide/en/elasticsearch/reference/current/system-config.html
echo "* - nofile 65536" > /etc/security/limits.d/elasticsearch
echo "vm.max_map_count = 262144" > /etc/sysctl.d/elasticsearch
