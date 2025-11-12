terraform {
  required_providers {
    talos = {
      source = "siderolabs/talos"
    }
  }
}

locals {
  # Prefer object inputs, fall back to legacy scalars
  cluster_name       = try(var.meta.cluster_name, var.talos_k8s_cluster_name)
  cluster_vip_domain = try(var.network.vip_domain, var.talos_k8s_cluster_vip_domain)
  api_port           = try(var.network.api_port, var.talos_k8s_cluster_endpoint_port)
  cluster_vip        = try(var.network.vip, var.talos_k8s_cluster_vip)
  talos_version      = try(var.versions.talos, var.talos_version)
  k8s_version        = try(var.versions.kubernetes, var.k8s_version)
  network_gateway    = try(var.network.gateway, var.talos_network_gateway)
  name_servers       = try(var.network.dns_servers, var.talos_name_servers)
  install_disk_device= try(var.install.disk_device, var.talos_install_disk_device)
  install_image_url  = try(var.install.image_url, var.talos_install_image_url)
  cp_network         = length(var.cp_network) > 0 ? var.cp_network : var.talos_control_plane_vms_network

  talos_k8s_cluster_endpoint = "https://api.${local.cluster_vip_domain}:${local.api_port}"
  control_plane_ip_addresses = [for cp in local.cp_network : cp.ip]

  talos_mc_defaults = {
    topology_region     = local.cluster_name
    talos_version       = local.talos_version
    talos_k8s_cluster_domain = var.talos_k8s_cluster_domain
    network_gateway     = local.network_gateway
    install_disk_device = local.install_disk_device
    install_image_url   = local.install_image_url
    name_servers        = local.name_servers
    talos_k8s_cluster_endpoint = local.talos_k8s_cluster_endpoint
  }

  cilium_inline_manifest = var.include_cilium && var.cilium_manifests != "" ? {
    cluster = {
      inlineManifests = [
        {
          name     = "cilium"
          contents = var.cilium_manifests
        }
      ]
    }
  } : {}

  cilium_inline_manifest_patch = var.include_cilium && var.cilium_manifests != "" ? yamlencode(local.cilium_inline_manifest) : ""
}

data "talos_machine_configuration" "this" {
  machine_type       = var.machine_type
  machine_secrets    = var.machine_secrets
  cluster_name       = local.cluster_name
  cluster_endpoint   = local.talos_k8s_cluster_endpoint
  talos_version      = "v${local.talos_version}"
  kubernetes_version = "v${local.k8s_version}"
  docs               = false
  examples           = false

  config_patches = concat(
    [templatefile("${path.root}/modules/talos-config-templates/common.yaml.tftpl", local.talos_mc_defaults)],
    var.machine_type == "controlplane" && var.include_cilium && length(local.cilium_inline_manifest_patch) > 0 ? [local.cilium_inline_manifest_patch] : []
  )
}
