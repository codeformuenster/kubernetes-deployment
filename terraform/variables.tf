// variable "docker_version" {
//   # default = "17.12.0~ce-0~ubuntu"
//   default = "18.06.0~ce~3-0~ubuntu"
// }

variable "kubernetes_version" {
  default = "v1.11.2"
}

// variable "kubernetes_version" {
//   default = "stable-1.11"
// }

variable "scaleway_region" {
  default = "par1"
}

variable "scaleway_server_type" {
  default = "C2S"
}

// variable "ctpl_count" {
//   default = 1
//   description = "Number of nodes in total, including one for control plane"
// }

variable "server_count" {
  default = 3
  description = "Number of servers in total, including one for control plane"
}

variable "private_key" {
  type = "string"
  default = "~/.ssh/id_rsa"
  description = "The path to your private ssh-key to access the nodes"
}

variable "weave_password" {}

variable "scaleway_organization" {}
variable "scaleway_token" {}


provider "local" {
  version = "~> 1.1"
}

provider "external" {
  version = "~> 1.0"
}

provider "null" {
  version = "~> 1.0"
}
