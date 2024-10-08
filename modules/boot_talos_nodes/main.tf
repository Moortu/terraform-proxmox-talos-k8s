locals {
  talos_k8s_cluster_endpoint = "https://${var.talos_k8s_cluster_domain}:${var.talos_k8s_cluster_endpoint_port}"
}

# resource "terraform_data" "inline-manifests" {
#   depends_on = [
#     data.external.kustomize_cilium,
#   ]

#   input = [
#     {
#       # required, is used as CNI and is needed for Talos to report nodes as ready
#       name     = "cilium"
#       contents = data.external.kustomize_cilium.result.manifests
#     }
#   ]
# }

# see https://registry.terraform.io/providers/siderolabs/talos/0.6.0/docs/resources/machine_configuration_apply
resource "talos_machine_configuration_apply" "control-planes" {
  depends_on = [
    data.talos_machine_configuration.cp,
    proxmox_virtual_environment_download_file.talos_iso
    # terraform_data.inline-manifests
  ]
  for_each = {
    for idx, cp in local.control-planes_network : idx => cp
  }

  client_configuration        = talos_machine_secrets.talos.client_configuration
  machine_configuration_input = data.talos_machine_configuration.cp.machine_configuration

  node = each.value.vm_name
  endpoint = each.value.ip

  config_patches = [
    templatefile("${path.module}/talos-config/control-plane.yaml.tftpl", {
      topology_zone     = each.value.node_name,
      cluster_domain    = var.talos_k8s_cluster_domain,
      cluster_endpoint  = local.talos_k8s_cluster_endpoint,
      network_interface = each.value.network_interface_name,
      network_ip_prefix = var.network_ip_prefix,
      network_gateway   = var.network_gateway,
      hostname          = each.value.vm_name,
      ipv4_local        = each.value.ip,
      ipv4_vip          = var.talos_k8s_cluster_vip,
      inline_manifests  = "" #jsonencode(terraform_data.inline-manifests.output)
    }),
  ]
}

# see https://registry.terraform.io/providers/siderolabs/talos/0.6.0-alpha.1/docs/resources/machine_configuration_apply
resource "talos_machine_configuration_apply" "worker-nodes" {
  depends_on = [
    data.talos_machine_configuration.wn,
    local.workers_network
  ]
  for_each = {
    for idx, wn in local.workers_network : idx => wn
  }

  client_configuration        = talos_machine_secrets.talos.client_configuration
  machine_configuration_input = data.talos_machine_configuration.wn.machine_configuration

  node = each.value.vm_name
  endpoint = each.value.ip

  # config_patches = concat([
  #   templatefile("${path.module}/talos-config/worker-node.yaml.tftpl", {
  #     topology_zone     = each.value.target_server,
  #     cluster_domain    = var.talos_k8s_cluster_domain,
  #     network_interface = each.value.network_interface_name,
  #     network_ip_prefix = var.network_ip_prefix,
  #     network_gateway   = var.network_gateway,
  #     hostname          = each.value.vm_name,
  #     ipv4_local        = each.value.ip,
  #     ipv4_vip          = var.talos_k8s_cluster_vip,
  #   }),
  #   templatefile("${path.module}/talos-config/node-labels.yaml.tftpl", {
  #     node_labels = jsonencode(each.value.node_labels),
  #   })
  # ],
  #   [
  #     for disk in each.value.data_disks : templatefile(
  #     "${path.module}/talos-config/worker-node-disk.yaml.tftpl",
  #     {
  #       disk_device = "/dev/${disk.device_name}",
  #       mount_point = disk.mount_point,
  #     })
  #   ]
  # )
}

# see https://registry.terraform.io/providers/siderolabs/talos/0.6.0-alpha.1/docs/resources/machine_bootstrap
resource "talos_machine_bootstrap" "this" {
  depends_on = [
    talos_machine_configuration_apply.control-planes,
    talos_machine_configuration_apply.worker-nodes
  ]

  client_configuration = talos_machine_secrets.talos.client_configuration
  node                 = talos_machine_configuration_apply.control-planes[0].node
}

# see https://registry.terraform.io/providers/siderolabs/talos/0.6.0-alpha.1/docs/data-sources/cluster_health
# TODO check and fix

# unfortunately, this does not really check, wait and retry for the cluster to
# be ready but instead errors and fails when unable to connect to nodes that
# are in the process of getting ready
#
# data "talos_cluster_health" "ready" {
#   depends_on = [null_resource.talos-cluster-up]
#
#   client_configuration = talos_machine_secrets.this.client_configuration
#   endpoints            = [for i, mac in macaddress.talos-control-plane: data.external.mac-to-ip.result[mac.address]]
#   control_plane_nodes  = [for i, mac in macaddress.talos-control-plane : data.external.mac-to-ip.result[mac.address]]
#   worker_nodes         = [for i, mac in macaddress.talos-worker : data.external.mac-to-ip.result[mac.address]]
# }