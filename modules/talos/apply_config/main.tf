resource "talos_machine_configuration_apply" "this" {
  for_each = { for idx, node in var.nodes_network : idx => node }

  client_configuration        = var.client_configuration
  machine_configuration_input = var.machine_configuration

  node     = each.value.vm_name
  endpoint = each.value.ip

  config_patches = [
    templatefile("${path.root}/${var.config_template_path}/${each.value.type == "control" ? "control-plane" : "worker-node"}.yaml.tftpl", {
      topology_zone     = each.value.node_name
      cluster_domain    = var.cluster_domain
      cluster_endpoint  = var.cluster_endpoint
      network_interface = each.value.network_interface_name
      network_ip_prefix = var.network_ip_prefix
      network_gateway   = var.network_gateway
      hostname          = each.value.vm_name
      ipv4_local        = each.value.ip
      ipv4_vip          = var.cluster_vip
      taints_enabled    = lookup(each.value, "taints_enabled", true)
    })
  ]
}
