#!/usr/bin/env bash

server_id=$1

apt update
apt -y -o Dpkg::Options::="--force-confnew" install base-files
apt -y upgrade
apt -y install apt-transport-https jq fish ethtool

curl https://packages.cloud.google.com/apt/doc/apt-key.gpg \
  | apt-key add -

# echo 'deb http://apt.kubernetes.io/ kubernetes-xenial main' \
#   > /etc/apt/sources.list.d/kubernetes.list

echo 'deb http://apt.kubernetes.io/ kubernetes-xenial-unstable main' \
  > /etc/apt/sources.list.d/kubernetes.list

apt update
apt -y install docker.io kubelet kubeadm kubectl kubernetes-cni

# temporary workaround
rmdir /etc/kubernetes/manifests

# workaround since nodes are referenced by hostnames instead of ips (?)
# echo "$server_id.priv.cloud.scaleway.com" > /etc/hostname
echo "$server_id.pub.cloud.scaleway.com" > /etc/hostname
reboot
