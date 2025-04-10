variable "talos_iso_destination_filename" {
  description = "Filename of the Talos iso image to store"
  type        = string
  # %version% is replaced by talos_version
  default     = "talos-%talos_version%-metal-secureboot-amd64.iso"
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

variable "central_iso_storage" {
  description = "If true, download ISO to a single location and use it for all nodes. If false, download to each Proxmox node."
  type        = bool
  default     = true
  
  validation {
    condition     = can(tobool(var.central_iso_storage))
    error_message = "The central_iso_storage value must be a boolean (true or false)."
  }
}