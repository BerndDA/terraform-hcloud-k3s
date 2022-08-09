output "api_loadbalancer_ip" {
  value       = module.infra.api_loadbalancer_ip
  description = "the IP of the API loadbalancer"
}

output "k3s_token" {
  value       = module.k3s.k3s_token
  description = "the secret k3s token"
}