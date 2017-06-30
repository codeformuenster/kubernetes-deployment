#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

apt -q update
apt -yq install apt-transport-https

curl https://packages.cloud.google.com/apt/doc/apt-key.gpg \
  | apt-key add -

# echo 'deb http://apt.kubernetes.io/ kubernetes-xenial-unstable main' \
echo 'deb http://apt.kubernetes.io/ kubernetes-xenial main' \
  > /etc/apt/sources.list.d/kubernetes.list

apt -q update
apt -yq upgrade
apt -yq install docker.io kubeadm

# for rook
# https://github.com/rook/rook/blob/master/Documentation/k8s-pre-reqs.md
# apt -y install ceph-common

# for elasticsearch
# https://www.elastic.co/guide/en/elasticsearch/reference/current/system-config.html

cat > /etc/sysctl.d/elasticsearch.conf <<EOF
vm.max_map_count = 262144
fs.file-max = 65536
EOF

cat > /etc/security/limits.d/elasticsearch.conf <<EOF
* - nofile 65536
root - nofile 65536
EOF
sysctl --system

# log versions of docker, kubeadm
docker version
kubeadm version
