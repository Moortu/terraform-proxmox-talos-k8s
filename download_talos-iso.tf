locals {
  talos_iso_image_location = "${var.talos_iso_destination_storage_pool}:iso/${replace(var.talos_iso_destination_filename, "%version%", var.talos_version)}"
}

# replace with talos_image factory_urls and talos_image_factory_schematic 
# https://registry.terraform.io/providers/siderolabs/talos/0.6.0-alpha.1/docs/data-sources/image_factory_urls
# https://registry.terraform.io/providers/siderolabs/talos/0.6.0-alpha.1/docs/resources/image_factory_schematic

# see https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_download_file
resource "proxmox_virtual_environment_download_file" "talos-iso" {
  content_type      = "iso"
  datastore_id      = var.talos_iso_destination_storage_pool
  file_name         = replace(var.talos_iso_destination_filename, "%version%", var.talos_version)
  node_name         = var.talos_iso_destination_server != "" ? var.talos_iso_destination_server : keys(var.proxmox_nodes)[0]
  overwrite         = false
  url               = var.talos_iso_download_url
}