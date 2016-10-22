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

# FIXME
# temporary fix needed, see
# https://github.com/kubernetes/kubernetes/issues/34884#issuecomment-255357287

# needed for elasticsearch since v5.0
sysctl -w vm.max_map_count=262144

# add kubernetes labels to docker log output
echo 'DOCKER_OPTS="--log-opt labels=io.kubernetes.container.hash,io.kubernetes.container.name,io.kubernetes.pod.name,io.kubernetes.pod.namespace,io.kubernetes.pod.uid"' > /etc/default/docker

# workaround since nodes are referenced by hostnames instead of ips (?)
# echo "$server_id.priv.cloud.scaleway.com" > /etc/hostname
echo "$server_id.pub.cloud.scaleway.com" > /etc/hostname
reboot
