resource "hcloud_firewall" "default_firewall" {
  name = "${var.cluster_name}-firewall"
  rule {
    description = "allow icmp (ping)"
    direction   = "in"
    protocol    = "icmp"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    description = "allow all TCP on internal network"
    direction   = "in"
    protocol    = "tcp"
    port        = "any"
    source_ips = [
      "10.0.0.0/16"
    ]
  }

  rule {
    description = "allow all UDP on internal network"
    direction   = "in"
    protocol    = "udp"
    port        = "any"
    source_ips = [
      "10.0.0.0/16"
    ]
  }
}

resource "hcloud_firewall" "firewall_allow_ssh" {
  name = "${var.cluster_name}-ssh-firewall"

  rule {
    description = "allow ssh access"
    direction   = "in"
    protocol    = "tcp"
    port        = "22"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
}
