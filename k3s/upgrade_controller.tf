locals {
  upgrade_main   = <<EOL
        kubectl apply --kubeconfig ${var.kubeconfig_file} -f - <<-EOF
        apiVersion: upgrade.cattle.io/v1
        kind: Plan
        metadata:
          name: k3s-server
          namespace: system-upgrade
          labels:
            k3s-upgrade: server
        spec:
          concurrency: 1
          version: ${var.k3s_version}
          nodeSelector:
            matchExpressions:
              - {key: node-role.kubernetes.io/master, operator: In, values: ["true"]}
          serviceAccountName: system-upgrade
          tolerations:
          - key: "CriticalAddonsOnly"
            operator: "Equal"
            value: "true"
            effect: "NoSchedule"
          cordon: true
          upgrade:
            image: rancher/k3s-upgrade
      EOF
  EOL
  upgrade_worker = <<EOL
        kubectl apply --kubeconfig ${var.kubeconfig_file} -f - <<-EOF
        apiVersion: upgrade.cattle.io/v1
        kind: Plan
        metadata:
          name: k3s-agent
          namespace: system-upgrade
          labels:
            k3s-upgrade: agent
        spec:
          concurrency: 1
          version: ${var.k3s_version}
          nodeSelector:
            matchExpressions:
              - {key: node-role.kubernetes.io/master, operator: NotIn, values: ["true"]}
          serviceAccountName: system-upgrade
          prepare:
            image: rancher/k3s-upgrade
            args: ["prepare", "k3s-server"]
          cordon: true
          upgrade:
            image: rancher/k3s-upgrade
      EOF
  EOL
}


resource "null_resource" "upgrade_controller" {
  depends_on = [
    null_resource.cluster_init
  ]
  triggers = {
    first_main_ip = var.main_ips[0]
  }
  provisioner "local-exec" {
    command = "kubectl apply --kubeconfig ${var.kubeconfig_file} -f https://github.com/rancher/system-upgrade-controller/releases/download/v0.13.2/system-upgrade-controller.yaml"
  }
}

resource "null_resource" "k3s_upgrade" {
  count = 1
  depends_on = [
    null_resource.upgrade_controller
  ]
  triggers = {
    upgrade_k3s = var.k3s_version
  }
  provisioner "local-exec" {
    command = "kubectl wait deployment -n system-upgrade system-upgrade-controller --for condition=Available=True --timeout=90s --kubeconfig ${var.kubeconfig_file}"
  }
  provisioner "local-exec" {
    command = local.upgrade_main
  }
  provisioner "local-exec" {
    command = local.upgrade_worker
  }
} 
