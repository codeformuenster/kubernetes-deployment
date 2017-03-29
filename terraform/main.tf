
variable "count" {
  default = 3
}
variable "scaleway_server_type" {
  default = "VC1M"
}
variable "scaleway_server_nameprefix" {
  default = "kube"
}
variable "scaleway_region" {
  default = "par1"
}
variable "kubeadm_token" {}


provider "scaleway" {
  # organization = "" # or SCALEWAY_ORGANIZATION
  # token = "" # or SCALEWAY_TOKEN
  region = "${var.scaleway_region}"
}

data "scaleway_bootscript" "latest" {
  architecture = "x86_64"
  name_filter = "docker" # for built-in module xt_set
}

data "scaleway_image" "ubuntu" {
  architecture = "x86_64"
  name = "Ubuntu Xenial"
}

resource "scaleway_server" "kube" {
  count = "${var.count}"
  bootscript = "${data.scaleway_bootscript.latest.id}"
  image = "${data.scaleway_image.ubuntu.id}"
  name = "${var.scaleway_server_nameprefix}${count.index}"
  type = "VC1M"
  enable_ipv6 = false
  dynamic_ip_required = true

  volume {
    size_in_gb = 50
    type = "l_ssd"
  }
}

resource "null_resource" "prepare" {
  count = "${var.count}"
  /*# Changes to any instance of the cluster requires re-provisioning
  triggers {
    cluster_instance_ids = "${join(",", aws_instance.cluster.*.id)}"
  }*/

  connection {
    host = "${element(scaleway_server.kube.*.public_ip, count.index)}"
    type     = "ssh"
    user     = "root"
    # private_key = file("")
  }

  provisioner "file" {
    source = "./provision"
    destination = "/root/provision"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /root/provision/dependencies.sh",
      "/root/provision/dependencies.sh"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /root/provision/kubeadm.sh",
      "/root/provision/kubeadm.sh ${count.index} ${var.kubeadm_token} ${scaleway_server.kube.0.private_ip} ${scaleway_server.kube.0.public_ip}"
    ]
  }
}
