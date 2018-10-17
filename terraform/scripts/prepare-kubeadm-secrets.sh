#!/usr/bin/env bash
set -e

mkdir -p temp && cd temp

rm -f ca.crt ca.key kubeadm-discovery-token-ca-cert-hash kubeadm-token
curl -sSfL -O "https://storage.googleapis.com/kubernetes-release/release/$KUBERNETES_VERSION/bin/linux/amd64/kubeadm" \
  && chmod +x ./kubeadm

./kubeadm alpha phase certs ca --cert-dir "$PWD"

./kubeadm token generate \
  > kubeadm-token

openssl rsa -in ca.key -pubout -outform der | sha256sum | sed 's/-//;' \
  > kubeadm-discovery-token-ca-cert-hash

# openssl rand -base64 32 \
#   > weave-password
