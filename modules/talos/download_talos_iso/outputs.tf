output "talos_installer_iso_url" {
  description = "URL of the Talos secureboot installer ISO"
  value       = data.talos_image_factory_urls.generated_url.urls.installer_secureboot
}

output "talos_installer_iso_file_ids" {
  description = "Map of Proxmox node names to downloaded Talos installer ISO file id"
  value = {
    for node_name, res in proxmox_virtual_environment_download_file.talos_iso_per_node : node_name => "${local.datastore_id}:iso/${res.file_name}"
  }
}
