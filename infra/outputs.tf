output "main_ips" {
  value = hcloud_server.main-node.*.ipv4_address
}

output "worker_ips" {
  value = hcloud_server.worker-node.*.ipv4_address
}


output "api_loadbalancer_ip" {
  value = hcloud_load_balancer.api_load_balancer.ipv4
}
