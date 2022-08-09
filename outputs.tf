output "api_loadbalancer_ip" {
  value       = module.k3s.api_load_balancer_ip
  description = "the IP of the API loadbalancer"
}

output "k3s_token" {
  value       = module.k3s.k3s_token
  description = "the secret k3s token"
}