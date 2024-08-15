variable "talos_iso_download_url" {
  description = "Location to download the Talos iso image from"
  type        = string
  # %version% is replaced by talos_version
  default     = "https://github.com/siderolabs/talos/releases/download/v%version%/metal-amd64.iso"
}

variable "talos_iso_destination_filename" {
  description = "Filename of the Talos iso image to store"
  type        = string
  # %version% is replaced by talos_version
  default     = "talos-%version%-metal-amd64.iso"
}

variable "talos_iso_destination_server" {
  description = "Proxmox server to store the Talos iso image on"
  type        = string
  default     = "" #pve-node-01
}

variable "talos_iso_destination_storage_pool" {
  description = "Proxmox storage to store the Talos iso image on"
  type        = string
  default     = "local" #big-storage-data
}