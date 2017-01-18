#!/usr/bin/env bash

token=$1
master_ip_pub=$2

kubeadm join \
  --token $token \
  $master_ip_pub
