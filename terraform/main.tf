
provider "scaleway" {
  version = "1.5.1"
  organization = "${var.scaleway_organization}" # or SCALEWAY_ORGANIZATION
  token = "${var.scaleway_token}" # or SCALEWAY_TOKEN
  region = "${var.scaleway_region}"
}

resource "scaleway_ip" "server" {
  count = "${var.server_count}"
}

data "scaleway_image" "ubuntu" {
  architecture = "x86_64"
  name = "Ubuntu Bionic"
}

resource "scaleway_server" "server" {
  count =  "${var.server_count}"
  image = "${data.scaleway_image.ubuntu.id}"
  name = "${terraform.workspace}${count.index}"
  type = "${var.scaleway_server_type}"
  enable_ipv6 = false
  public_ip = "${element(scaleway_ip.server.*.ip, count.index)}"

  // template?
  provisioner "remote-exec" {
    script = "./scripts/bootstrap-server.sh"
  }
}

// ---


resource "null_resource" "kubeadm-secrets" {
  provisioner "local-exec" {

    command = "./scripts/prepare-kubeadm-secrets.sh"
    // working_dir = "./temp"
    environment {
      KUBERNETES_VERSION = "${var.kubernetes_version}"
    }
  }
}

resource "null_resource" "control-plane" {
  count = 1
  depends_on = ["null_resource.kubeadm-secrets"]
  connection {
    host = "${element(scaleway_server.server.*.public_ip, count.index)}"
  }

  // provisioner "file" {
  //   source = "./temp/ca.crt"
  //   destination = "/etc/kubernetes/pki/ca.crt"
  // }
  //
  // provisioner "file" {
  //   source = "./temp/ca.key"
  //   destination = "/etc/kubernetes/pki/ca.key"
  // }

  provisioner "remote-exec" {
    inline = [<<EOF
      kubeadm init \
        --apiserver-advertise-address="${scaleway_server.server.0.private_ip}" \
        --apiserver-cert-extra-sans="${scaleway_server.server.0.public_ip}" \
        --kubernetes-version="${var.kubernetes_version}" \
        --token="${file("${path.module}/temp/kubeadm-token")}"
EOF
    ]
  }

//   provisioner "local-exec" {
//     on_failure = "continue"
//     command = <<EOF
//       ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "root@${scaleway_server.server.0.public_ip}" \
//         cat /etc/kubernetes/admin.conf \
//           | sed -e "s/${scaleway_server.server.0.private_ip}/${scaleway_server.server.0.public_ip}/g" \
//             > ./kube-config.conf
// EOF
//   }

  provisioner "local-exec" {
    on_failure = "continue"
    command = <<EOF
      ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "root@${scaleway_server.server.0.public_ip}" \
        cat /etc/kubernetes/admin.conf \
          | sed -e "s/${scaleway_server.server.0.private_ip}/${scaleway_server.server.0.public_ip}/g" \
            > ./kube-config.conf
EOF
  }
}

data "external" "kubeadm-join-command" {
  program = ["./scripts/remote-exec.sh"]
  query = {
    dest = "root@${scaleway_server.server.0.public_ip}"
    cmd = "kubeadm token create --print-join-command"
  }
  depends_on = ["scaleway_server.controlplane"]
  // on_failure = "continue"
}


// #!/usr/bin/env bash
// set -e
// eval "$(jq -r '@sh "dest=\(.dest) cmd=\(.cmd)"')"
//
// ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$dest" "$cmd" \
//   | xargs --null -I {} jq -n --arg data "{}" '{"data": $data}'







resource "null_resource" "worker-node" {
  count = "${var.server_count - 1}"
  depends_on = ["null_resource.kubeadm-secrets"]
  connection {
    host = "${element(scaleway_server.server.*.public_ip, count.index + 1)}"
  }

  provisioner "remote-exec" {
    inline = [<<EOF
      kubeadm join "${scaleway_server.server.0.private_ip}:6443" \
        --token="${file("${path.module}/temp/kubeadm-token")}" \
        --discovery-token-ca-cert-hash="${file("${path.module}/temp/kubeadm-discovery-token-ca-cert-hash")}"
EOF
    ]
  }
}
