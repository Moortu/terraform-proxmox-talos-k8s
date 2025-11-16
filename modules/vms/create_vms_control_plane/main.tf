terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
    }
    macaddress = {
      source = "ivoronin/macaddress"
    }
    time = {
      source = "opentofu/time"
    }
  }
}

locals {
  # Collect and sort control planes
  vm_control_planes_unsorted = flatten([
    for node_name, node in var.proxmox_nodes : [
      for control_plane in node.control_planes : merge(control_plane, { node_name = node_name })
    ]
  ])

  vm_control_planes_map = { for cp in local.vm_control_planes_unsorted : cp.name => cp }
  vm_control_planes = [for name in sort(keys(local.vm_control_planes_map)) : local.vm_control_planes_map[name]]
}

module "vms" {
  source = "../vm_base"

  providers = {
    proxmox    = proxmox
    macaddress = macaddress
    time       = time
  }

  vm_specs = {
    name_prefix = var.control_plane_name_prefix
    first_id    = var.control_plane_first_id
    first_ip    = var.control_plane_first_ip
    count       = length(local.vm_control_planes)
  }

  network = {
    dhcp    = var.talos_network_dhcp
    cidr    = var.talos_network_cidr
    gateway = var.talos_network_gateway
  }

  iso = {
    image_location = var.talos_iso_image_location
  }

  proxmox_nodes = var.proxmox_nodes
  vm_configs    = local.vm_control_planes
  vm_type       = "control_plane"

  # Image-based boot support
  disk_image_locations     = var.talos_disk_image_locations
  proxmox_api_url          = var.proxmox_api_url
  proxmox_user             = var.proxmox_user
  proxmox_api_token_id     = var.proxmox_api_token_id
  proxmox_api_token_secret = var.proxmox_api_token_secret
}
