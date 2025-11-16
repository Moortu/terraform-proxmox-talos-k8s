# Configure Proxmox provider
# provider "proxmox" {
#   endpoint  = var.proxmox_api_url
#   api_token = "${var.proxmox_user}!${var.proxmox_api_token_id}=${var.proxmox_api_token_secret}"
#   insecure  = true
#   tmp_dir   = "/var/tmp"
  
#   ssh {
#     agent    = true
#     username = var.proxmox_user
#   }
# }


module "talos_image" {
  source = "../../../modules/talos/download_talos_image"

  # Sane defaults (module has defaults for most). Only set the essentials.
  talos_iso_destination_storage_pool = var.talos_iso_destination_storage_pool
  talos_version                      = var.talos_version
  talos_architecture                 = var.talos_architecture
  proxmox_nodes                      = var.proxmox_nodes
}


# module "talos_iso" {
#   source = "../../../modules/download_talos_iso"

#   talos_iso_destination_filename     = var.talos_iso_destination_filename
#   talos_iso_destination_server       = var.talos_iso_destination_server
#   talos_iso_destination_storage_pool = var.talos_iso_destination_storage_pool
#   central_iso_storage                = var.central_iso_storage
#   talos_version                      = var.talos_version
#   talos_architecture                 = var.talos_architecture
#   download_method                    = var.download_method
#   local_download_dir                 = var.local_download_dir
#   proxmox_nodes                      = var.proxmox_nodes
# }
