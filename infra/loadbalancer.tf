resource "hcloud_load_balancer" "api_load_balancer" {
  name               = "${var.cluster_name}-api-lb"
  load_balancer_type = "lb11"
  location           = var.location
}

resource "hcloud_load_balancer_target" "api_load_balancer_target" {
  depends_on = [
    hcloud_load_balancer_network.srvnetwork
  ]
  type             = "label_selector"
  load_balancer_id = hcloud_load_balancer.api_load_balancer.id
  label_selector   = "node-type=${var.cluster_name}-main"
  use_private_ip   = true
}

resource "hcloud_load_balancer_network" "srvnetwork" {
  load_balancer_id = hcloud_load_balancer.api_load_balancer.id
  network_id       = hcloud_network.network.id
  ip               = "10.0.0.5"
}

resource "hcloud_load_balancer_service" "load_balancer_service" {
  load_balancer_id = hcloud_load_balancer.api_load_balancer.id
  protocol         = "tcp"
  listen_port      = 6443
  destination_port = 6443
}
