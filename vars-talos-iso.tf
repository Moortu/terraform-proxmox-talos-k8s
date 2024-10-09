variable "talos_iso_destination_filename" {
  description = "Filename of the Talos iso image to store"
  type        = string
  # %version% is replaced by talos_version
  default     = "talos-%version%-metal-secureboot-amd64.iso"
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