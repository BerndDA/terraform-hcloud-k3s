locals {
  ccm_secret = <<EOL
    kubectl apply --kubeconfig ./kube_config.yaml -f - <<-EOF
        apiVersion: "v1"
        kind: "Secret"
        metadata:
          namespace: 'kube-system'
          name: 'hcloud'
        stringData:
          network: "${var.cluster_name}-net"
          token: "${var.hetzner_token}"
    EOF
  EOL
}

resource "null_resource" "ccm" {
  depends_on = [
    null_resource.cluster_init
  ]
  triggers = {
    first_main_ip = var.main_ips[0]
  }
  provisioner "local-exec" {
    command = local.ccm_secret
  }
  provisioner "local-exec" {
    command = "kubectl apply --kubeconfig ./kube_config.yaml -f https://github.com/hetznercloud/hcloud-cloud-controller-manager/releases/latest/download/ccm-networks.yaml"
  }
}
