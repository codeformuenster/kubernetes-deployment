#!/usr/bin/env bash

server_ip_pub=$1
# server_id=$1

# KUBE_COMPONENT_LOGLEVEL="--v=2"

kubeadm init \
  --api-advertise-addresses $server_ip_pub
  # --api-external-dns-names $server_id.pub.cloud.scaleway.com

kubectl apply --filename https://git.io/weave-kube
  # https://github.com/weaveworks/weave-kube/releases/download/latest_release/weave-daemonset.yaml

# kubectl taint nodes --all dedicated-
