output "talos_iso_path" {
  description = "Path to the Talos ISO in Proxmox"
  value       = local.talos_iso_path
}

output "talos_installer_image_url" {
  description = "URL of the Talos installer image"
  value       = module.talos_iso.talos_installer_image_url
}

output "talos_iso_image_location" {
  description = "ISO image location for VMs"
  value       = local.talos_iso_path
}
