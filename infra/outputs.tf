output "main_ips" {
  value = concat(hcloud_server.main-node.*.ipv4_address, hcloud_server_network.main-node-network.*.ip)
}

output "worker_ips" {
  value = concat(hcloud_server.worker-node.*.ipv4_address, hcloud_server_network.worker-node-network.*.ip)
}


output "api_loadbalancer_ip" {
  value = hcloud_load_balancer.api_load_balancer.ipv4
}
