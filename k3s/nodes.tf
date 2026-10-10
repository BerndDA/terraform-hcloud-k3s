resource "random_id" "k3s_token" {
  byte_length = 8
}

locals {
  cluster_init       = <<EOL
        curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION="${var.k3s_version}" K3S_TOKEN="${random_id.k3s_token.hex}" INSTALL_K3S_EXEC="server \
        --disable-cloud-controller \
        --disable servicelb \
        --disable traefik \
        --disable local-storage \
        --disable metrics-server \
        --write-kubeconfig-mode=644 \
        --node-name="$(hostname -f)" \
        --cluster-cidr=10.244.0.0/16 \
        --etcd-expose-metrics=true \
        --flannel-backend=wireguard-native \
        --kube-controller-manager-arg="bind-address=0.0.0.0" \
        --kube-proxy-arg="metrics-bind-address=0.0.0.0" \
        --kube-scheduler-arg="bind-address=0.0.0.0" \
        --node-taint CriticalAddonsOnly=true:NoSchedule \
        --kubelet-arg="cloud-provider=external" \
        --advertise-address=$(hostname -I | awk '{print $2}') \
        --node-ip=$(hostname -I | awk '{print $2}') \
        --node-external-ip=$(hostname -I | awk '{print $1}') \
        --flannel-iface=$(ls -d1 /sys/class/net/en* | awk -F/ '{print $5}') \
        --cluster-init --tls-san=${var.api_loadbalancer_ip}" sh -
  EOL
  wait_for_api       = <<EOL
        until kubectl describe nodes --kubeconfig ${var.kubeconfig_file}
        do
            echo Wait for API to be available...
            sleep 1
        done
  EOL
  wait_for_interface = <<EOL
        until ping -c 1 -W 1 10.0.0.10
        do
            echo Wait for interface to be available...
            sleep 1
        done
  EOL
  master_init        = <<EOL
        curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION="${var.k3s_version}" K3S_TOKEN="${random_id.k3s_token.hex}" INSTALL_K3S_EXEC="server \
        --disable-cloud-controller \
        --disable servicelb \
        --disable traefik \
        --disable local-storage \
        --disable metrics-server \
        --write-kubeconfig-mode=644 \
        --node-name="$(hostname -f)" \
        --cluster-cidr=10.244.0.0/16 \
        --etcd-expose-metrics=true \
        --flannel-backend=wireguard-native \
        --kube-controller-manager-arg="bind-address=0.0.0.0" \
        --kube-proxy-arg="metrics-bind-address=0.0.0.0" \
        --kube-scheduler-arg="bind-address=0.0.0.0" \
        --node-taint CriticalAddonsOnly=true:NoSchedule \
        --kubelet-arg="cloud-provider=external" \
        --advertise-address=$(hostname -I | awk '{print $2}') \
        --node-ip=$(hostname -I | awk '{print $2}') \
        --node-external-ip=$(hostname -I | awk '{print $1}') \
        --flannel-iface=$(ls -d1 /sys/class/net/en* | awk -F/ '{print $5}') \
        --server https://${var.api_loadbalancer_ip}:6443 --tls-san=${var.api_loadbalancer_ip}" sh -
  EOL
  worker_init        = <<EOL
        curl -sfL https://get.k3s.io | K3S_TOKEN="${random_id.k3s_token.hex}" INSTALL_K3S_VERSION="${var.k3s_version}" K3S_URL=https://${var.api_loadbalancer_ip}:6443 INSTALL_K3S_EXEC="agent \
        --node-name="$(hostname -f)" \
        --kubelet-arg="cloud-provider=external" \
        --node-ip=$(hostname -I | awk '{print $2}') \
        --node-external-ip=$(hostname -I | awk '{print $1}') \
        --flannel-iface=$(ls -d1 /sys/class/net/en* | awk -F/ '{print $5}')" sh -
  EOL
  modify_kubeconfig  = <<EOL
        cp /etc/rancher/k3s/k3s.yaml /root/kubeconfig.yaml && \
        sed -i 's/127.0.0.1/${var.api_loadbalancer_ip}/g' /root/kubeconfig.yaml && \
        sed -i 's/default/${var.cluster_name}/g' /root/kubeconfig.yaml

  EOL
  copy_cube_config   = <<EOL
        scp -o "StrictHostKeyChecking no" -i ${local_file.ssh_private_key.filename} root@${var.main_ips[0]}:/root/kubeconfig.yaml ${var.kubeconfig_file}
  EOL
  # Run on the first main node. If a cluster is already reachable through the API
  # load balancer (i.e. the other control-plane nodes are alive and have etcd
  # quorum), join it as an additional server instead of bootstrapping a new
  # etcd with --cluster-init. This makes the first main node recreatable: on a
  # fresh apply nothing answers the LB and we bootstrap; on a replace the
  # surviving mains answer and we rejoin instead of forking the cluster.
  first_main_init = <<EOL
        if curl -sk --connect-timeout 5 --max-time 10 https://${var.api_loadbalancer_ip}:6443/ >/dev/null 2>&1; then
          echo "Existing cluster reachable via API load balancer; joining as an additional server."
          ${local.master_init}
        else
          echo "No cluster reachable; bootstrapping a new cluster with --cluster-init."
          ${local.cluster_init}
        fi
  EOL
}

resource "local_file" "ssh_private_key" {
  content         = var.ssh_private_key
  filename        = "./id_${var.cluster_name}"
  file_permission = "0600"
}

resource "null_resource" "cluster_init" {
  depends_on = [

  ]
  triggers = {
    first_main_ip = var.main_ips[0]
  }

  connection {
    type        = "ssh"
    user        = "root"
    host        = var.main_ips[0]
    agent       = false
    private_key = var.ssh_private_key
  }
  provisioner "remote-exec" {
    inline = [
      local.wait_for_interface,
      local.first_main_init,
      local.modify_kubeconfig
    ]
  }
  provisioner "local-exec" {
    command = local.copy_cube_config
  }
  provisioner "local-exec" {
    command = local.wait_for_api
  }
}

resource "null_resource" "master_init" {
  depends_on = [
    null_resource.cluster_init
  ]
  count = var.num_main_nodes - 1
  triggers = {
    main_ip = var.main_ips[count.index + 1]
  }

  connection {
    type        = "ssh"
    user        = "root"
    host        = var.main_ips[count.index + 1]
    agent       = false
    private_key = var.ssh_private_key
  }

  provisioner "remote-exec" {
    on_failure = continue
    inline = [
      local.wait_for_interface,
      local.master_init
    ]
  }
}

resource "null_resource" "worker_init" {
  depends_on = [
    null_resource.cluster_init
  ]
  count = var.num_worker_nodes
  triggers = {
    worker_ip = var.worker_ips[count.index]
  }

  connection {
    type        = "ssh"
    user        = "root"
    host        = var.worker_ips[count.index]
    agent       = false
    private_key = var.ssh_private_key
  }

  provisioner "remote-exec" {
    on_failure = continue
    inline = [
      local.wait_for_interface,
      local.worker_init,
    ]
  }
}

