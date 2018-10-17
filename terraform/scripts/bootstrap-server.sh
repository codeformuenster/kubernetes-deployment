#!/usr/bin/env bash
set -e

docker_version="18.06.0~ce~3-0~ubuntu"

export DEBIAN_FRONTEND=noninteractive
apt() {
  # https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=288778
  command apt -qq -o=Dpkg::Use-Pty=0 -o=Dpkg::Progress-Fancy=0 "$@"
}

apt update && apt upgrade -y
# apt install -y apt-transport-https ca-certificates curl git
apt install -y apt-transport-https

modprobe ip_vs_wrr ip_vs_sh ip_vs ip_vs_rr
cat << EOF >> /etc/modules-load.d/ipvs
ip_vs_wrr
ip_vs_sh
ip_vs
ip_vs_rr
EOF

echo "deb https://download.docker.com/linux/ubuntu bionic stable" | tee /etc/apt/sources.list.d/docker.list \
  && curl -fsSL "https://download.docker.com/linux/ubuntu/gpg" | apt-key add -
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list \
  && curl -fsSL "https://packages.cloud.google.com/apt/doc/apt-key.gpg" | apt-key add -

apt update
# apt install -y --no-install-recommends docker-ce="${docker_version}"
# apt install -y kubeadm
apt install -y --no-install-recommends docker-ce="${docker_version}" kubeadm
apt-mark hold docker-ce

docker version
kubeadm version

# https://kubernetes.io/docs/setup/independent/install-kubeadm/#verify-the-mac-address-and-product-uuid-are-unique-for-every-node
# You can get the MAC address of the network interfaces using the command `ip link` or `ifconfig -a`
# The product_uuid can be checked by using the command `sudo cat /sys/class/dmi/id/product_uuid`
#
# output these


# https://www.elastic.co/guide/en/elasticsearch/reference/current/system-config.html

ulimit -n 512000
cat > /etc/security/limits.d/open_files.conf <<EOF
root - nofile 512000
* - nofile 512000
EOF

ulimit -u 4096
cat > /etc/security/limits.d/processes.conf <<EOF
root - nproc 4096
* - nproc 4096
EOF

sysctl -w vm.max_map_count=262144
echo "vm.max_map_count = 262144" >> /etc/sysctl.conf

kubeadm config images pull

# disable swap
swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# install open-iscsi for openebs
apt-get install -y open-iscsi
service open-iscsi restart

# FIXME enable automatic security-updates
# https://blog.filippo.io/psa-enable-automatic-updates-please/
