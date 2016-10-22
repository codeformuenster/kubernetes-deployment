#!/usr/bin/env fish

# example
# ./fetch-credetials.fish kube01 cfm
# kubectl config use-context cfm

# FIXME find master/apiserver by query

set server_name $argv[1]
set cluster_name $argv[2]

set server_ids (scw ps --all --filter tags=kubeadm --quiet)

set --erase servers
for server_id in $server_ids
  set servers (string join "" (printf "$servers" | jq -c '.[]') (scw inspect $server_id | jq -c '.[]') | jq -s -c '.')
end

set server_id (echo "$servers" | jq -r  '.[] | select(.name=="'$server_name'") | .id')
set server_ip_pub (echo "$servers" | jq -r  '.[] | select(.name=="'$server_name'") | .public_ip.address')


mkdir --parents ~/.kube/certs
# rm ~/.kube/certs/cfm*

scw exec --wait $server_id "kubectl --kubeconfig /etc/kubernetes/admin.conf config view --raw -o json | jq -r '.clusters[] | select(.name | contains (\"kubernetes\")) | .cluster.\"certificate-authority-data\"' | base64 --decode" > ~/.kube/certs/$cluster_name.ca.crt

scw exec --wait $server_id "kubectl --kubeconfig /etc/kubernetes/admin.conf config view --raw -o json | jq -r '.users[] | select(.name | contains (\"admin\")) | .user.\"client-key-data\"' | base64 --decode" > ~/.kube/certs/$cluster_name.key

scw exec --wait $server_id "kubectl --kubeconfig /etc/kubernetes/admin.conf config view --raw -o json | jq -r '.users[] | select(.name | contains (\"admin\")) | .user.\"client-certificate-data\"' | base64 --decode" > ~/.kube/certs/$cluster_name.crt

kubectl config set-cluster $cluster_name --server "https://$server_ip_pub:6443" --certificate-authority="$HOME/.kube/certs/$cluster_name.ca.crt"

kubectl config set-credentials $cluster_name --username=$cluster_name --client-key="$HOME/.kube/certs/$cluster_name.key" --client-certificate="$HOME/.kube/certs/$cluster_name.crt"

kubectl config set-context $cluster_name --cluster $cluster_name --user $cluster_name

# kubectl config use-context $cluster_name
