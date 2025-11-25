module "talos_image" {
  source = "../../../modules/talos/download_talos_image"

  # Sane defaults (module has defaults for most). Only set the essentials.
  talos_image_destination_storage_pool = var.talos_image_destination_storage_pool
  talos_version                      = var.talos_version
  talos_architecture                 = var.talos_architecture
  proxmox_nodes                      = var.proxmox_nodes
}

# module "talos_iso" {
#   source = "../../../modules/talos/download_talos_iso"

#   # Sane defaults (module has defaults for most). Only set the essentials.
#   talos_image_destination_storage_pool = var.talos_image_destination_storage_pool
#   talos_version                      = var.talos_version
#   talos_architecture                 = var.talos_architecture
#   proxmox_nodes                      = var.proxmox_nodes
# }

