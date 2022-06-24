module "clusterA" {
  source          = "../../"
  hetzner_token   = "xxx"
  cluster_name    = "dev1"
  ssh_file        = "./ssh_id"
  kubeconfig_file = "./devA.yaml"
  main_pool_config = {
    node_type = "cx11"
    num_nodes = 2
  }
  worker_pool_config = {
    node_type = "cx21"
    num_nodes = 1
  }
}

module "clusterB" {
  source          = "../../"
  hetzner_token   = "xxx"
  cluster_name    = "dev2"
  ssh_file        = "./ssh_id2"
  kubeconfig_file = "./devB.yaml"
  main_pool_config = {
    node_type = "cx11"
    num_nodes = 2
  }
  worker_pool_config = {
    node_type = "cx21"
    num_nodes = 1
  }
}
