variable "hetzner_token" {
  default = "4PYXqJGQZV6QkuVxQJhQlKyFsqpBVXW6MSfTtbSWSJBU8ku0BoLXH3y7KzDAWdrg"
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
  cluster_name    = "bernd"
  ssh_public_key  = tls_private_key.ssh.public_key_openssh
  ssh_private_key = tls_private_key.ssh.private_key_openssh
  main_pool_config = {
    node_type = "cax11"
    num_nodes = 1
  }
  worker_pool_config = {
    node_type = "cax21"
    num_nodes = 1
  }
  k3s_version = "v1.27.1+k3s1"
  location    = "fsn1"
  image       = "103907373"
}

