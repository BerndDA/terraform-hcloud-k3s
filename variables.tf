variable "hetzner_token" {
  type    = string
  sensitive = true
}

variable "cluster_name" {
  type    = string
  default = "dev"
}

variable "image" {
  type    = string
  default = "debian-11"
}

variable "k3s_version" {
  type    = string
  default = "v1.24.1+k3s1"
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
}
