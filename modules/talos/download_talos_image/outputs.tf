output "talos_installer_image_url" {
  description = "URL of the Talos installer image (non-secureboot)"
  value       = data.talos_image_factory_urls.generated_url.urls.installer_secureboot
}


# Disk image specific outputs for image-based flow
output "talos_disk_image_url" {
  description = "URL of the Talos secureboot disk image (.raw.zst)"
  value       = data.talos_image_factory_urls.generated_url.urls.disk_image_secureboot
}

output "talos_disk_image_file_ids" {
  description = "Map of Proxmox node names to downloaded file id"
  value = {
    for node_name, res in proxmox_virtual_environment_download_file.talos_image_per_node : node_name => "${local.datastore_id}:import/${res.file_name}"
  }
}