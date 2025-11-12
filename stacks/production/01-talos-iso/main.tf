# Configure Proxmox provider
provider "proxmox" {
  endpoint  = var.proxmox_api_url
  api_token = "${var.proxmox_user}!${var.proxmox_api_token_id}=${var.proxmox_api_token_secret}"
  insecure  = true
  tmp_dir   = "/var/tmp"
  
  ssh {
    agent    = true
    username = var.proxmox_user
  }
}

locals {
  talos_iso_filename = replace(var.talos_iso_destination_filename, "%talos_version%", var.talos_version)
  talos_iso_path     = "${var.talos_iso_destination_storage_pool}:iso/${local.talos_iso_filename}"
  
  talos_iso_central_node = var.central_iso_storage ? (var.talos_iso_destination_server != "" ? var.talos_iso_destination_server : keys(var.proxmox_nodes)[0]) : null
  
  talos_iso_node_paths = {
    for node in keys(var.proxmox_nodes) : node => local.talos_iso_path
  }
}

module "talos_iso" {
  source = "../../../modules/download_talos_iso"

  talos_iso_destination_filename     = var.talos_iso_destination_filename
  talos_iso_destination_server       = var.talos_iso_destination_server
  talos_iso_destination_storage_pool = var.talos_iso_destination_storage_pool
  central_iso_storage                = var.central_iso_storage
  talos_version                      = var.talos_version
  talos_architecture                 = var.talos_architecture
  proxmox_nodes                      = var.proxmox_nodes
}
