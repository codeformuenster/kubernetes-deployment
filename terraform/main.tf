
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
variable "scaleway_organization" {}
variable "scaleway_token" {}


provider "scaleway" {
  organization = "${var.scaleway_organization}" # or SCALEWAY_ORGANIZATION
  token = "${var.scaleway_token}" # or SCALEWAY_TOKEN
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

# FIXME does not work as expected :/
# see https://github.com/hashicorp/terraform/issues/14175

resource "scaleway_ip" "kube" {
  count = "${var.count}"
  # id = "d6a7eab0-c9c0-4ea5-9b40-6f49c559fa18"
}

resource "scaleway_server" "kube" {
  count = "${var.count}"
  bootscript = "${data.scaleway_bootscript.latest.id}"
  image = "${data.scaleway_image.ubuntu.id}"
  name = "${var.scaleway_server_nameprefix}${count.index}"
  type = "${var.scaleway_server_type}"
  enable_ipv6 = false
  public_ip = "${element(scaleway_ip.kube.*.ip, count.index)}"

  volume {
    size_in_gb = 50
    type = "l_ssd"
  }
}

resource "null_resource" "prepare" {
  count = "${var.count}"

  connection {
    host = "${element(scaleway_server.kube.*.public_ip, count.index)}"
    type     = "ssh"
    user     = "root"
  }

  provisioner "file" {
    source = "./provision"
    destination = "/root/provision"
  }

  provisioner "remote-exec" {
    inline = [
      "cd /root/provision",
      "chmod +x dependencies.sh",
      "./dependencies.sh"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "cd /root/provision",
      "chmod +x kubeadm.sh",
      "./kubeadm.sh ${count.index} ${var.kubeadm_token} ${scaleway_server.kube.0.private_ip} ${scaleway_server.kube.0.public_ip}"
    ]
  }
}
