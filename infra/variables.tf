variable "cluster_name" {
  type = string
}

variable "image" {
  type = string
}

variable "main_pool_config" {
  type = object({
    num_nodes = number
    node_type = string
  })
}

variable "worker_pool_config" {
  type = object({
    num_nodes = number
    node_type = string
  })
}

variable "location" {
  type = string
}

