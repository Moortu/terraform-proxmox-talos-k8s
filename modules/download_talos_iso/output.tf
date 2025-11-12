# We don't export the actual resource anymore since they're of different types
# Instead we provide the structured paths and configuration through talos_iso_locations
output "talos_iso" {
  description = "Whether the Talos ISO was successfully downloaded"
  value = var.central_iso_storage ? "Downloaded to central location" : "Downloaded to each node"
}

output "talos_iso_url" {
  description = "URL of the Talos ISO image (non-secureboot)"
  value       = data.talos_image_factory_urls.generated_url.urls.iso
}

output "talos_installer_image_url" {
  description = "URL of the Talos installer image (non-secureboot)"
  value       = data.talos_image_factory_urls.generated_url.urls.installer
}

output "debug_download_url" {
  description = "The exact URL being used to download the Talos ISO"
  value       = local.talos_iso_download_url
}

output "talos_iso_locations" {
  description = "Map of Proxmox node names to Talos ISO file locations"
  value = var.central_iso_storage ? {
    for node_name in keys(var.proxmox_nodes) : node_name => "${var.talos_iso_destination_storage_pool}:iso/${replace(var.talos_iso_destination_filename, "%talos_version%", var.talos_version)}"
  } : {
    for node_name in keys(var.proxmox_nodes) : node_name => "${var.talos_iso_destination_storage_pool}:iso/${replace(var.talos_iso_destination_filename, "%talos_version%", var.talos_version)}"
  }
}

output "talos_iso_central_node" {
  description = "Proxmox node where the central ISO is stored (if using central_iso_storage)"
  value       = var.central_iso_storage ? (var.talos_iso_destination_server != "" ? var.talos_iso_destination_server : keys(var.proxmox_nodes)[0]) : null
}