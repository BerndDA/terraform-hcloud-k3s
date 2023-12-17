locals {
  csi_secret = <<EOL
    kubectl apply --kubeconfig ${var.kubeconfig_file} -f - <<-EOF
        apiVersion: "v1"
        kind: "Secret"
        metadata:
          namespace: 'kube-system'
          name: 'hcloud-csi'
        stringData:
          token: "${var.hetzner_token}"
      EOF
  EOL
}

resource "null_resource" "csi" {
  depends_on = [
    null_resource.cluster_init
  ]
  triggers = {
    first_main_ip = var.main_ips[0]
  }
  provisioner "local-exec" {
    command = local.csi_secret
  }
  provisioner "local-exec" {
    command = "helm repo add hcloud https://charts.hetzner.cloud && helm repo update hcloud && helm install hcloud-csi hcloud/hcloud-csi -n kube-system --kubeconfig ${var.kubeconfig_file}"
  }
}
