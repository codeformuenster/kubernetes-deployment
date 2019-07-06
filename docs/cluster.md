# Some notes about cluster creation


## Create server instance on Scaleway

Image: Ubuntu Bionic
Region: Paris 1
Server: C2L Baremetal - 8 Dedicated X86 64bit 32 GB Memory

Name: kube2-2
Advanced / Boot Script: x86_64 mainline 4.19.53 rev1

# 10.1.166.41 kube2-0
# 10.1.85.181 kube2-1
# 10.1.224.117 kube2-2


## Loadbalancer


## Prepare

```bash

cat << EOF > prepare.sh
#!/usr/bin/env bash

# unattended package installation
# FIXME make default via some config
export DEBIAN_FRONTEND=noninteractive

# https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=288778
alias apt='command apt -qq -o=Dpkg::Use-Pty=0 -o=Dpkg::Progress-Fancy=0'

# containerd
VERSION="1.2.7"
curl -sfSOL "https://storage.googleapis.com/cri-containerd-release/cri-containerd-${VERSION}.linux-amd64.tar.gz"
curl "https://storage.googleapis.com/cri-containerd-release/cri-containerd-${VERSION}.linux-amd64.tar.gz.sha256"
sha256sum "cri-containerd-${VERSION}.linux-amd64.tar.gz"

tar --no-overwrite-dir --directory / -xzf "cri-containerd-${VERSION}.linux-amd64.tar.gz"

# apt install libseccomp2
# installed by default on scaleway/ubuntu
systemctl daemon-reload
systemctl restart containerd
systemctl enable containerd


curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list

apt update 
apt upgrade -y
apt-mark hold kubelet kubeadm kubectl
apt install -y --allow-change-held-packages kubelet kubeadm kubectl


# for kubeadm
modprobe br_netfilter
echo "br_netfilter" >> /etc/modules-load.d/kubeadm
# FIXME howto reload just that file instead of explicit modprobe before?


# for kubeadm or containerd? or kube-router?
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.d/99-kubernetes-cri.conf
sysctl --system

# for elasticsearch
echo "vm.max_map_count = 262144" >> /etc/sysctl.conf
sysctl --system


# for some weird situations we saw earlier?
# was once increased to 512000..
# default on scaleway/ubuntu is 1024??
ulimit -n 128000
cat > /etc/security/limits.d/open_files.conf <<EOF2
root - nofile 128000
* - nofile 128000
EOF2

# default on scaleway/ubuntu is 128336?
# ulimit -u 4096
# cat > /etc/security/limits.d/processes.conf <<EOF
# root - nproc 4096
# * - nproc 4096
# EOF

# swap is disabled by default on scaleway/ubuntu
# swapoff -a
# sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# for openebs
systemctl enable iscsid
systemctl start iscsid

# pre pull images
kubeadm config images pull


# enable `unattended-upgrades` for security?
EOF

chmod +x ./prepare.sh
./prepare.sh
```


## init or join

**initial master**
```bash
kubeadm config print init-defaults

cat << EOF > kubeadm-config.yaml 
apiVersion: kubeadm.k8s.io/v1beta1
kind: ClusterConfiguration
kubernetesVersion: stable
controlPlaneEndpoint: "kube.codeformuenster.org:6443"
networking:
  podSubnet: 192.168.0.0/16
EOF

# check scaleway loadbalancer entries for kube.codeformuenster.org

kubeadm init --config=kubeadm-config.yaml --experimental-upload-certs

KUBECONFIG=/etc/kubernetes/admin.conf \
  kubectl taint nodes --all node-role.kubernetes.io/master-
```

**aditional masters**
```bash

# on existing master if certs are removed from secrets (after 2h)
kubeadm init phase upload-certs --experimental-upload-certs

# on existing master if token are outdated (after 30min)
kubeadm token create --print-join-command

# on the aditional master run a command like this with the infos from the commands above
kubeadm join kube.codeformuenster.org:6443 --token l8eyof.rxzg8dzstjp2ykfs \
  --discovery-token-ca-cert-hash sha256:465ff3d15819e8cfe2c69939056b1afbcf7bc9ec5c7b444dee19b51d2c146ca2 \
  --experimental-control-plane --certificate-key 2ff6c5ad3853912e063c9f774205a06a0ddbd708e0a4722f18aabe5072b98b67

KUBECONFIG=/etc/kubernetes/admin.conf \
  kubectl get nodes -o wide

KUBECONFIG=/etc/kubernetes/admin.conf \
  kubectl taint nodes --all node-role.kubernetes.io/master-


# CNI
kubectl apply --kustomize github.com/codeformuenster/kubernetes-deployment//sources/kube-router/overlay

# remove kube-proxy and cleanup
kubectl -n kube-system delete daemonsets kube-proxy
kubectl apply -f https://raw.githubusercontent.com/codeformuenster/kubernetes-deployment/master/sources/kube-router/kube-proxy-cleanup.yaml
kubectl -n kube-system logs -f -l k8s-app=kube-proxy-cleanup
kubectl -n kube-system delete daemonsets kube-proxy-cleanup
```

## kubeconfig

scp root@212.47.232.30:/etc/kubernetes/admin.conf ~/.kube/config.d/cfm-kube-cert-admin.config
