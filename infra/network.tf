data "hcloud_location" "loc" {
  name = var.location
}

resource "hcloud_network" "network" {
  name     = "${var.cluster_name}-net"
  ip_range = "10.0.0.0/16"
}

resource "hcloud_network_subnet" "network-subnet" {
  type         = "cloud"
  network_id   = hcloud_network.network.id
  network_zone = data.hcloud_location.loc.network_zone
  ip_range     = "10.0.0.0/16"
}

