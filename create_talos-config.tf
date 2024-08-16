locals {
  depends_on = [ 
    proxmox_virtual_environment_vm.talos-control-plane
  ]

  cluster_endpoint = "https://${var.talos_k8s_cluster_domain}:${var.talos_k8s_cluster_endpoint_port}"
  storage_mnt      = "/var/mnt/storage"

  #TODO, use the network_gateway to match 3 parts of the ip address to make 75% sure it's the right one
  flattened_ips = flatten(flatten([for cp in proxmox_virtual_environment_vm.talos-control-plane : cp.ipv4_addresses]))
  control_plane_ip-addresses = [for ip in local.flattened_ips : ip if ip != "127.0.0.1"]
  # default talos_machine_configuration values
  talos_mc_defaults = {
    topology_region     = var.talos_k8s_cluster_name,
    talos_version       = var.talos_version,
    network_gateway     = var.network_gateway,
    install_disk_device = var.install_disk_device,
    install_image_url   = replace(var.talos_machine_install_image_url, "%version%", var.talos_version),
  }
}

# see https://registry.terraform.io/providers/siderolabs/talos/0.6.0-alpha.1/docs/resources/machine_secrets
resource "talos_machine_secrets" "talos" {
  talos_version = "v${var.talos_version}"
}

# see https://registry.terraform.io/providers/siderolabs/talos/0.6.0-alpha.1/docs/data-sources/client_configuration
data "talos_client_configuration" "this" {
  depends_on = [ local.flattened_ips, local.control_plane_ip-addresses ]
  client_configuration = talos_machine_secrets.talos.client_configuration
  cluster_name         = var.talos_k8s_cluster_name
  endpoints            = concat([var.talos_k8s_cluster_vip], [control_plane_ip-addresses])
}

# see https://registry.terraform.io/providers/siderolabs/talos/0.6.0-alpha.1/docs/data-sources/machine_configuration
data "talos_machine_configuration" "cp" {
  machine_type       = "controlplane"
  machine_secrets    = talos_machine_secrets.this.machine_secrets
  cluster_name       = var.talos_k8s_cluster_name
  cluster_endpoint   = local.cluster_endpoint
  talos_version      = "v${var.talos_version}"
  kubernetes_version = "v${var.k8s_version}"
  docs               = false
  examples           = false

  config_patches = [
    templatefile("${path.module}/talos-config/default.yaml.tpl", local.talos_mc_defaults),
  ]
}

# see https://registry.terraform.io/providers/siderolabs/talos/0.6.0-alpha.1/docs/data-sources/machine_configuration
data "talos_machine_configuration" "wn" {
  machine_type       = "worker"
  machine_secrets    = talos_machine_secrets.this.machine_secrets
  cluster_name       = var.talos_k8s_cluster_name
  cluster_endpoint   = local.cluster_endpoint
  talos_version      = "v${var.talos_version}"
  kubernetes_version = "v${var.k8s_version}"
  docs               = false
  examples           = false

  config_patches = [
    templatefile("${path.module}/talos-config/default.yaml.tpl", local.talos_mc_defaults),
  ]
}