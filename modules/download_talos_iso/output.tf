output "talos_iso" {
  description = "Talos iso"
  value = proxmox_virtual_environment_download_file.talos_iso
}

output "talos_image_url" {
  value = data.talos_image_factory_urls.this.urls.installer_secureboot
}