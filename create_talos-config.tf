locals {
  talos_k8s_cluster_endpoint = "https://${var.talos_k8s_cluster_domain}:${var.talos_k8s_cluster_endpoint_port}"
  storage_mnt      = "/var/mnt/storage"

  control_plane_ip-addresses = [for cp in local.control-planes_network : cp.ip]

  # default talos_machine_configuration values
  talos_mc_defaults = {
    topology_region     = var.talos_k8s_cluster_name,
    talos_version       = var.talos_version,
    network_gateway     = var.network_gateway,
    install_disk_device = var.install_disk_device,
    install_image_url   = data.talos_image_factory_urls.this.urls.installer_secureboot
  }
}

# see https://registry.terraform.io/providers/siderolabs/talos/0.6.0/docs/resources/machine_secrets
resource "talos_machine_secrets" "talos" {
  talos_version = "v${var.talos_version}"
}

# see https://registry.terraform.io/providers/siderolabs/talos/0.6.0/docs/data-sources/client_configuration
data "talos_client_configuration" "this" {
  depends_on           = [ local.control_plane_ip-addresses ]
  client_configuration = talos_machine_secrets.talos.client_configuration
  cluster_name         = var.talos_k8s_cluster_name
  endpoints            = concat([var.talos_k8s_cluster_vip], local.control_plane_ip-addresses)
}

# see https://registry.terraform.io/providers/siderolabs/talos/0.6.0/docs/data-sources/machine_configuration
data "talos_machine_configuration" "cp" {
  machine_type       = "controlplane"
  machine_secrets    = talos_machine_secrets.talos.machine_secrets
  cluster_name       = var.talos_k8s_cluster_name
  cluster_endpoint   = local.talos_k8s_cluster_endpoint
  talos_version      = "v${var.talos_version}"
  kubernetes_version = "v${var.k8s_version}"
  docs               = false
  examples           = false

  config_patches = [
    templatefile("${path.module}/talos-config/common.yaml.tftpl", local.talos_mc_defaults),
  ]
}

# see https://registry.terraform.io/providers/siderolabs/talos/0.6.0/docs/data-sources/machine_configuration
data "talos_machine_configuration" "wn" {
  machine_type       = "worker"
  machine_secrets    = talos_machine_secrets.talos.machine_secrets
  cluster_name       = var.talos_k8s_cluster_name
  cluster_endpoint   = local.talos_k8s_cluster_endpoint
  talos_version      = "v${var.talos_version}"
  kubernetes_version = "v${var.k8s_version}"
  docs               = false
  examples           = false

  config_patches = [
    templatefile("${path.module}/talos-config/common.yaml.tftpl", local.talos_mc_defaults),
  ]
}