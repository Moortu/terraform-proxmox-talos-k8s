locals {
  cilium_manifest = file("${path.root}/manifests/cilium/cilium-manifest.yaml")
}

# see https://registry.terraform.io/providers/siderolabs/talos/0.6.0/docs/resources/machine_configuration_apply
resource "talos_machine_configuration_apply" "control_planes" {
  for_each = { for idx, cp in var.control_planes_network : idx => cp }

  client_configuration        = var.talos_machine_secrets.client_configuration
  machine_configuration_input = var.talos_machine_configuration_control_planes.machine_configuration

  node = each.value.vm_name
  endpoint = each.value.ip

  config_patches = [
    templatefile("${path.root}/talos-config-templates/control-plane.yaml.tftpl", {
      topology_zone     = each.value.node_name,
      cluster_domain    = var.talos_k8s_cluster_domain,
      cluster_endpoint  = var.talos_k8s_cluster_endpoint,
      network_interface = each.value.network_interface_name,
      network_ip_prefix = var.talos_network_ip_prefix,
      network_gateway   = var.talos_network_gateway,
      hostname          = each.value.vm_name,
      ipv4_local        = each.value.ip,
      ipv4_vip          = var.talos_k8s_cluster_vip,
      inline_manifests  = local.cilium_manifest
    })
  ]
}

# see https://registry.terraform.io/providers/siderolabs/talos/0.6.0/docs/resources/machine_configuration_apply
resource "talos_machine_configuration_apply" "worker_nodes" {
  for_each = { for idx, wn in var.workers_network : idx => wn }

  client_configuration        = var.talos_machine_secrets.client_configuration
  machine_configuration_input = var.talos_machine_configuration_workers.machine_configuration

  node = each.value.vm_name
  endpoint = each.value.ip

  config_patches = concat([
    templatefile("${path.root}/talos-config-templates/worker-node.yaml.tftpl", {
      topology_zone     = each.value.node_name,
      cluster_domain    = var.talos_k8s_cluster_domain,
      network_interface = each.value.network_interface_name,
      network_ip_prefix = var.talos_network_ip_prefix,
      network_gateway   = var.talos_network_gateway,
      hostname          = each.value.vm_name,
      ipv4_local        = each.value.ip,
      ipv4_vip          = var.talos_k8s_cluster_vip,
    }),
    templatefile("${path.root}/talos-config-templates/node-labels.yaml.tftpl", {
      node_labels = "worker",
    })
  ],
    # [
    #   for disk in each.value.data_disks : templatefile(
    #   "${path.root}/talos-config-templates/worker-node-disk.yaml.tftpl",
    #   {
    #     disk_device = "/dev/${disk.device_name}",
    #     mount_point = disk.mount_point,
    #   })
    # ]
  )
}

# see https://registry.terraform.io/providers/siderolabs/talos/0.6.0/docs/resources/machine_bootstrap
resource "talos_machine_bootstrap" "this" {
  depends_on = [
    talos_machine_configuration_apply.control_planes,
    # talos_machine_configuration_apply.worker_nodes
  ]

  client_configuration = var.talos_machine_secrets.client_configuration
  node                 = var.control_planes_network[0].ip
}

# see https://registry.terraform.io/providers/siderolabs/talos/0.6.0/docs/data-sources/cluster_health
# data "talos_cluster_health" "ready" {
#   depends_on = [talos_machine_bootstrap.this]

#   client_configuration = var.talos_machine_secrets.client_configuration
#   endpoints            = [var.talos_k8s_cluster_vip]
#   control_plane_nodes  = [for i in var.control_planes_network : i.ip]
#   # worker_nodes         = [for i in var.workers_network :i.ip]

#   skip_kubernetes_checks = true
#   timeouts = {
#     read = "3m"
#   }
# }

resource "time_sleep" "wait_for_talos_cluster_bootstrap" {
  depends_on = [talos_machine_bootstrap.this]
  create_duration = "3m"
}


resource "talos_cluster_kubeconfig" "kubeconfig" {
  depends_on = [time_sleep.wait_for_talos_cluster_bootstrap]

  client_configuration = var.talos_machine_secrets.client_configuration
  node                 = var.control_planes_network[0].ip
}

data "talos_client_configuration" "talosconfig" {
  cluster_name         = "example-cluster"
  client_configuration = var.talos_machine_secrets.client_configuration
  nodes                = [ for node in var.control_planes_network: node.ip ]
}

resource "local_sensitive_file" "export_talosconfig" {
  content    = data.talos_client_configuration.talosconfig.talos_config
  filename   = "${path.root}/generated/talosconfig" #rename to config, place in .talos
}

resource "local_sensitive_file" "export_kubeconfig" {
  content    = talos_cluster_kubeconfig.kubeconfig.kubeconfig_raw
  filename   = "${path.root}/generated/kubeconfig" #rename to config place in .kube
}