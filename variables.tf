variable "hetzner_token" {
  type        = string
  sensitive   = true
  description = "Hetzner cloud API token"
}

variable "cluster_name" {
  type        = string
  default     = "dev"
  description = "Name of your cluster. Also used to pre/postfix resources"
}

variable "image" {
  type        = string
  default     = "debian-11"
  description = "Type of OS image used for all nodes"
}

variable "k3s_version" {
  type        = string
  default     = "v1.24.1+k3s1"
  description = "K3S version to install on the nodes"
}

variable "location" {
  type        = string
  default     = "nbg1"
  description = "Location of all resources within Hetzner Cloud (fsn1|nbg1|hel1|ash)"
}

variable "ssh_file" {
  type        = string
  default     = "./id_ssh"
  description = "File and Path to ssh key. If you want to create multiple clusters in the same project, you have to use different keys."
}

variable "ssh_private_key" {
  type = string
}

variable "ssh_public_key" {
  type = string
}

variable "kubeconfig_file" {
  type        = string
  default     = "./kube_config.yml"
  description = "File and Path of kubeconfig file to write"
}

variable "main_pool_config" {
  type = object({
    num_nodes = number
    node_type = string
  })
  default = {
    num_nodes = 3
    node_type = "cx11"
  }
  description = "Number and type of main nodes"
}

variable "worker_pool_config" {
  type = object({
    num_nodes = number
    node_type = string
  })
  default = {
    num_nodes = 3
    node_type = "cx21"
  }
  description = "Number and type of worker nodes"
}
