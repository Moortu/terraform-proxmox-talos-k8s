output "talos_iso" {
  description = "Talos iso"
  value = proxmox_virtual_environment_download_file.talos_iso
}

output "talos_iso_image_location" {
  value =  "${var.talos_iso_destination_storage_pool}:iso/${replace(var.talos_iso_destination_filename, "%version%", var.talos_version)}"
}

output "talos_image_url" {
  value = data.talos_image_factory_urls.this.urls.installer_secureboot
}