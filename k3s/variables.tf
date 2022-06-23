variable "main_ips" {
}
variable "worker_ips" {
}
variable "api_loadbalancer_ip" {
}
variable "cluster_name" {
}
variable "hetzner_token" {
}
variable "num_main_nodes" {
  type = number
}
variable "num_worker_nodes" {
  type = number
}
variable "k3s_version" {
}