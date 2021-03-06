variable "hetzner_token" {

}

terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
      version = ">=1.33.2"
    }
  }
}

provider "hcloud" {
  token = var.hetzner_token
}

module "k3s" {
  source          = "BerndDA/k3s/hcloud"
  version         = "0.1.6"
  # insert the 1 required variable here
  hetzner_token = var.hetzner_token
  cluster_name  = "bernd"
  main_pool_config = {
    node_type = "cx11"
    num_nodes = 3
  }
  worker_pool_config = {
    node_type = "cx21"
    num_nodes = 3
  }
  k3s_version = "v1.23.7+k3s1"
}

