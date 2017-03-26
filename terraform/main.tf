
provider "scaleway" {
  # organization = "" # or SCALEWAY_ORGANIZATION
  # token = "" # or SCALEWAY_TOKEN
  region = "ams1"
  # region = "par1"
}

data "scaleway_bootscript" "latest" {
  architecture = "x86_64"
  name_filter = "latest"
}

data "scaleway_image" "ubuntu" {
  architecture = "x86_64"
  name = "Ubuntu Xenial"
}


resource "scaleway_server" "kube" {
  count = 3
  bootscript = "${data.scaleway_bootscript.latest.id}"
  image = "${data.scaleway_image.ubuntu.id}"
  name = "kube_test${count.index}"
  type = "VC1M"
  # type = "C2S"
  enable_ipv6 = false
  dynamic_ip_required = true

  volume {
    size_in_gb = 50
    type = "l_ssd"
  }
}

resource "null_resource" "prepare" {
  count = 3
  /*# Changes to any instance of the cluster requires re-provisioning
  triggers {
    cluster_instance_ids = "${join(",", aws_instance.cluster.*.id)}"
  }*/

  provisioner "file" {
    source = "./provision"
    destination = "/root/provision"

    connection {
      host = "${element(scaleway_server.kube.*.public_ip, count.index)}"
      type     = "ssh"
      user     = "root"
      # private_key = file("")
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /root/provision/kubeadm.sh",
      "/root/provision/kubeadm.sh ${count.index} 48e9eb.c8620960850a6620 ${scaleway_server.kube.0.private_ip}"
    ]

    connection {
      host = "${element(scaleway_server.kube.*.public_ip, count.index)}"
      type     = "ssh"
      user     = "root"
      # private_key = file("")
    }
  }
}
