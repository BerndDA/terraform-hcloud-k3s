variable "main_ips" {
}
variable "worker_ips" {
}
variable "api_loadbalancer_ip" {
}
variable "cluster_name" {
}
variable "hetzner_token" {
  ephemeral = true
}
variable "num_main_nodes" {
  type = number
}
variable "num_worker_nodes" {
  type = number
}
variable "k3s_version" {
}
variable "system_upgrade_controller_version" {
  description = "Version of rancher/system-upgrade-controller to install"
  default     = "v0.19.2"
}
variable "ssh_private_key" {
}
variable "kubeconfig_file" {
}