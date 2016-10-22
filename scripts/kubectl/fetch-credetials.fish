#!/usr/bin/env fish

# example
# ./fetch-credetials.fish cfm
# kubectl config use-context cfm

set cluster_name $argv[1]

scw ps --all --filter "tags=master" --quiet | xargs echo -n | read --array server_ids
# only one master server for now
set server_id $server_ids[1]
set server_ip_pub (scw inspect $server_id | jq -r  '.[] | .public_ip.address')


mkdir --parents ~/.kube/certs
# rm ~/.kube/certs/$cluster_name*

scw exec --wait $server_id "kubectl --kubeconfig /etc/kubernetes/admin.conf config view --raw -o json | jq -r '.clusters[] | select(.name | contains (\"kubernetes\")) | .cluster.\"certificate-authority-data\"' | base64 --decode" > ~/.kube/certs/$cluster_name.ca.crt

scw exec --wait $server_id "kubectl --kubeconfig /etc/kubernetes/admin.conf config view --raw -o json | jq -r '.users[] | select(.name | contains (\"admin\")) | .user.\"client-key-data\"' | base64 --decode" > ~/.kube/certs/$cluster_name.key

scw exec --wait $server_id "kubectl --kubeconfig /etc/kubernetes/admin.conf config view --raw -o json | jq -r '.users[] | select(.name | contains (\"admin\")) | .user.\"client-certificate-data\"' | base64 --decode" > ~/.kube/certs/$cluster_name.crt

kubectl config set-cluster $cluster_name --server "https://$server_ip_pub:6443" --certificate-authority="$HOME/.kube/certs/$cluster_name.ca.crt"

kubectl config set-credentials $cluster_name --username=$cluster_name --client-key="$HOME/.kube/certs/$cluster_name.key" --client-certificate="$HOME/.kube/certs/$cluster_name.crt"

kubectl config set-context $cluster_name --cluster $cluster_name --user $cluster_name

# kubectl config use-context $cluster_name
