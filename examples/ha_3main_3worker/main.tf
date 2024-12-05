variable "hetzner_token" {
  default = "PEEdA8S1IA1OiMroEabWogWWh42fT8AwHgCZDKhGt6GrBnigu8i1hNd2GKaCv6xq"
}

terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = ">=1.38.2"
    }
  }
}

provider "hcloud" {
  token = var.hetzner_token
}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 3072
}

module "k3s" {
  source = "../.."
  #version         = "0.1.12"
  # insert the 1 required variable here
  hetzner_token   = var.hetzner_token
  cluster_name    = "testcluster"
  ssh_public_key  = tls_private_key.ssh.public_key_openssh
  ssh_private_key = tls_private_key.ssh.private_key_openssh
  main_pool_config = {
    node_type = "cax11"
    num_nodes = 3
  }
  worker_pool_config = {
    node_type = "cax21"
    num_nodes = 3
  }
  k3s_version = "v1.27.1+k3s1"
  location    = "fsn1"
  image       = "103907373"
}

