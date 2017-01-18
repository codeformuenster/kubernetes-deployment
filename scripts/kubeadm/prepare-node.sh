#!/usr/bin/env bash

server_id=$1

apt update
apt -y -o Dpkg::Options::="--force-confnew" install base-files
apt -y upgrade
apt -y install apt-transport-https jq fish ethtool

curl https://packages.cloud.google.com/apt/doc/apt-key.gpg \
  | apt-key add -

echo 'deb http://apt.kubernetes.io/ kubernetes-xenial main' \
  > /etc/apt/sources.list.d/kubernetes.list

apt update
apt -y install docker.io kubelet kubeadm kubectl kubernetes-cni

# for elasticsearch v5.0
sysctl -w vm.max_map_count=262144

# add kubernetes labels to docker log output
echo 'DOCKER_OPTS="--log-opt labels=io.kubernetes.container.hash,io.kubernetes.container.name,io.kubernetes.pod.name,io.kubernetes.pod.namespace,io.kubernetes.pod.uid"' > /etc/default/docker

# # workaround since nodes are referenced by hostnames instead of ips (?)
# # echo "$server_id.priv.cloud.scaleway.com" > /etc/hostname
# echo "$server_id.pub.cloud.scaleway.com" > /etc/hostname
# reboot
#
hostnamectl set-hostname "$server_id.pub.cloud.scaleway.com"
