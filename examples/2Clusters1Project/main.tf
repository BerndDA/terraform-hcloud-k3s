variable hetzner_token {}

module "clusterA" {
  source          = "BerndDA/k3s/hcloud"
  version         = "0.1.10"
  hetzner_token   = var.hetzner_token
  cluster_name    = "dev1"
  ssh_file        = "./ssh_id"
  kubeconfig_file = "./dev1.yaml"
  main_pool_config = {
    node_type = "cx11"
    num_nodes = 1
  }
  worker_pool_config = {
    node_type = "cx21"
    num_nodes = 2
  }
}

module "clusterB" {
  source          = "BerndDA/k3s/hcloud"
  version         = "0.1.10"
  hetzner_token   = var.hetzner_token
  cluster_name    = "dev2"
  ssh_file        = "./ssh_id2"
  kubeconfig_file = "./dev2.yaml"
  main_pool_config = {
    node_type = "cx11"
    num_nodes = 1
  }
  worker_pool_config = {
    node_type = "cx21"
    num_nodes = 2
  }
}
