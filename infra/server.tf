resource "hcloud_ssh_key" "default" {
  name       = "${var.cluster_name}-ssh"
  public_key = file("./id_ssh.pub")
}

resource "hcloud_placement_group" "main" {
  name = "main-group"
  type = "spread"
}

resource "hcloud_placement_group" "worker" {
  name = "worker-group"
  type = "spread"
}

resource "hcloud_server" "main-node" {
  count       = var.main_pool_config.num_nodes
  name        = "${var.cluster_name}-main-${count.index}"
  image       = var.image
  location    = "nbg1"
  ssh_keys    = [hcloud_ssh_key.default.name]
  server_type = var.main_pool_config.node_type
  labels = {
    "node-type" = "${var.cluster_name}-main"
  }
  placement_group_id = hcloud_placement_group.main.id
  firewall_ids = [ hcloud_firewall.default_firewall.id ]
  user_data    = <<EOL
  #cloud-config
  packages:
    - wireguard
    - apparmor
    - apparmor-utils
  package_upgrade: true
  EOL
}

resource "hcloud_server_network" "main-node-network" {
  count      = var.main_pool_config.num_nodes
  server_id  = hcloud_server.main-node[count.index].id
  network_id = hcloud_network.network.id
  ip         = cidrhost(hcloud_network_subnet.network-subnet.ip_range, 10 + count.index)
}

resource "hcloud_server" "worker-node" {
  count       = var.worker_pool_config.num_nodes
  name        = "${var.cluster_name}-worker-${count.index}"
  image       = var.image
  location    = "nbg1"
  ssh_keys    = [hcloud_ssh_key.default.name]
  server_type = var.worker_pool_config.node_type
  labels = {
    "node-type" = "${var.cluster_name}-worker"
  }
  placement_group_id = hcloud_placement_group.worker.id
  firewall_ids = [ hcloud_firewall.default_firewall.id ]
  user_data    = <<EOL
  #cloud-config
  packages:
    - wireguard
    - apparmor
    - apparmor-utils
  package_upgrade: true
  EOL
}

resource "hcloud_server_network" "worker-node-network" {
  count      = var.worker_pool_config.num_nodes
  server_id  = hcloud_server.worker-node[count.index].id
  network_id = hcloud_network.network.id
  ip         = cidrhost(hcloud_network_subnet.network-subnet.ip_range, 100 + count.index)
}
