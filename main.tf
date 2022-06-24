module "infra" {
  source             = "./infra"
  cluster_name       = var.cluster_name
  main_pool_config   = var.main_pool_config
  worker_pool_config = var.worker_pool_config
  image              = var.image
  location           = var.location
  ssh_file           = var.ssh_file
}

module "k3s" {
  source              = "./k3s"
  cluster_name        = var.cluster_name
  main_ips            = module.infra.main_ips
  worker_ips          = module.infra.worker_ips
  api_loadbalancer_ip = module.infra.api_loadbalancer_ip
  num_main_nodes      = var.main_pool_config.num_nodes
  num_worker_nodes    = var.worker_pool_config.num_nodes
  hetzner_token       = var.hetzner_token
  k3s_version         = var.k3s_version
  ssh_file            = var.ssh_file
  kubeconfig_file     = var.kubeconfig_file
}

