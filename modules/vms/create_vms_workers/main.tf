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
  # Collect and sort workers
  vm_workers_unsorted = flatten([
    for node_name, node in var.proxmox_nodes : [
      for worker in node.workers : merge(worker, { node_name = node_name })
    ]
  ])

  vm_workers_map = { for worker in local.vm_workers_unsorted : worker.name => worker }
  vm_workers = [for name in sort(keys(local.vm_workers_map)) : local.vm_workers_map[name]]
}

module "vms" {
  source = "../vm_base"

  providers = {
    proxmox    = proxmox
    macaddress = macaddress
    time       = time
  }

  vm_specs = {
    name_prefix = var.worker_node_name_prefix
    first_id    = var.worker_node_first_id
    first_ip    = var.worker_node_first_ip
    count       = length(local.vm_workers)
  }

  network = {
    dhcp    = var.talos_network_dhcp
    cidr    = var.talos_network_cidr
    gateway = var.talos_network_gateway
  }

  iso = {
    image_location = var.talos_image_location
  }

  proxmox_nodes = var.proxmox_nodes
  vm_configs    = local.vm_workers
  vm_type       = "worker"

  # Image-based boot support
  disk_image_locations     = var.talos_disk_image_locations
  proxmox_api_url          = var.proxmox_api_url
  proxmox_user             = var.proxmox_user
  proxmox_api_token_id     = var.proxmox_api_token_id
  proxmox_api_token_secret = var.proxmox_api_token_secret
}
