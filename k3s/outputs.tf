output "k3s_token" {
  value       = random_id.k3s_token.hex
  description = "the secret k3s token"
}
