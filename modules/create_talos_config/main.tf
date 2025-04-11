locals {
  talos_k8s_cluster_endpoint = "https://${var.talos_k8s_cluster_domain}:${var.talos_k8s_cluster_endpoint_port}"
  storage_mnt      = "/var/mnt/storage"

  control_plane_ip-addresses = [for cp in var.talos_control_plane_vms_network : cp.ip]

  # default talos_machine_configuration values
  talos_mc_defaults = {
    topology_region     = var.talos_k8s_cluster_name,
    talos_version       = var.talos_version,
    talos_k8s_cluster_domain = var.talos_k8s_cluster_domain,
    network_gateway     = var.talos_network_gateway,
    install_disk_device = var.talos_install_disk_device,
    install_image_url   = var.talos_install_image_url,
    name_servers        = var.talos_name_servers
  }
  # Create a YAML patch for the CNI and kube-proxy settings from the provided cilium_patch
  # Only create this patch if we have actual content
  cilium_cni_patch = length(var.cilium_patch) > 0 ? yamlencode(var.cilium_patch) : ""
  
  # Create the inline manifest configuration for Cilium
  # Only create this if we have actual manifests to include
  cilium_inline_manifest = var.include_cilium_inline_manifests && var.cilium_manifests != "" ? {
    cluster = {
      inlineManifests = [
        {
          name = "cilium"
          contents = var.cilium_manifests
        }
      ]
    }
  } : {}
  
  # Convert to YAML for the patch, only if we have valid inline manifests
  cilium_inline_manifest_patch = var.include_cilium_inline_manifests && var.cilium_manifests != "" ? yamlencode(local.cilium_inline_manifest) : ""
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
    templatefile("${path.root}/modules/talos-config-templates/common.yaml.tftpl", local.talos_mc_defaults),
    # Only include the cilium_cni_patch if it's not empty
    length(local.cilium_cni_patch) > 0 ? local.cilium_cni_patch : "",
    # Only include the cilium_inline_manifest_patch if inline manifests are enabled and it's not empty
    var.include_cilium_inline_manifests && length(local.cilium_inline_manifest_patch) > 0 ? local.cilium_inline_manifest_patch : "",
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
    templatefile("${path.root}/modules/talos-config-templates/common.yaml.tftpl", local.talos_mc_defaults),
    # Only include the cilium_cni_patch if it's not empty
    length(local.cilium_cni_patch) > 0 ? local.cilium_cni_patch : "",
    # Only include the cilium_inline_manifest_patch if inline manifests are enabled and it's not empty
    var.include_cilium_inline_manifests && length(local.cilium_inline_manifest_patch) > 0 ? local.cilium_inline_manifest_patch : "",
  ]
}