#!/usr/bin/env bash

server_ip_pub=$1

kubeadm init \
  --use-kubernetes-version v1.5.2 \
  --api-advertise-addresses $server_ip_pub
  # --api-external-dns-names $server_id.pub.cloud.scaleway.com

kubectl apply \
  --filename https://github.com/weaveworks/weave-kube/releases/download/latest_release/weave-daemonset.yaml
