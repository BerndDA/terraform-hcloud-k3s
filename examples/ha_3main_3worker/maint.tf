variable "hetzner_token" {

}

module "k3s" {
  source  = "BerndDA/k3s/hcloud"
  version = "0.1.4"
  # insert the 1 required variable here
  hetzner_token = var.hetzner_token
  cluster_name  = "bernd"
}
