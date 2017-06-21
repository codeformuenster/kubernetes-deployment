#!/usr/bin/env bash

node_num=$1
token=$2
master_ip_private=$3
master_ip_public=$4

if [ "$node_num" = "0" ]; then

  # echo "apiServerCertSANs: [\"$master_ip_public\"]" >> ./master-configuration.yaml
  echo "api:" >> ./master-configuration.yaml
  echo "  advertiseAddress: \"$master_ip_public\"" >> ./master-configuration.yaml
  echo "token: \"$token\"" >> ./master-configuration.yaml

  kubeadm init --config master-configuration.yaml

  KUBECONFIG=/etc/kubernetes/admin.conf \
    kubectl apply --filename https://git.io/weave-kube-1.6

  # # experimental: write audit-log on host to /var/log/kubernetes
  # cat /etc/kubernetes/manifests/kube-apiserver.yaml \
  #   | docker run -i giantswarm/yaml-jq:0.1.0 '
  #     .spec.containers[0].volumeMounts
  #       |= .+ [{"mountPath": "/var/log/kubernetes", "name": "audit"}] |
  #     .spec.volumes
  #       |= .+ [{"hostPath": {"path": "/var/log/kubernetes"}, "name": "audit"}]' \
  #         > /etc/kubernetes/manifests/kube-apiserver.yaml

else
  kubeadm join --token $token $master_ip_private:6443
  # kubeadm join --token $token $master_ip_public:6443
fi
