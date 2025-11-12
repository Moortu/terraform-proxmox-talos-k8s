variable "talos_version" {
  description = "Talos version to use"
  # https://github.com/siderolabs/talos/releases
  type        = string
  default     = "1.11.5"
}

variable "talos_architecture" {
  description = "CPU architecture for Talos image (amd64 or arm64)"
  type        = string
  default     = "amd64"
}

variable "talos_iso_destination_filename" {
  description = "Filename of the Talos iso image to store"
  type        = string
  default     = "talos-%talos_version%-metal-secureboot-amd64.iso"
}

variable "talos_iso_destination_server" {
  description = "Proxmox server to store the Talos iso image on"
  type        = string
  default     = ""
}

variable "talos_iso_destination_storage_pool" {
  description = "Proxmox storage to store the Talos iso image on"
  type        = string
  default     = "local"
}

variable "central_iso_storage" {
  description = "If true, download ISO to a single location and use it for all nodes"
  type        = bool
  default     = true
}

variable "proxmox_nodes" {
  description = "Proxmox servers on which the talos cluster will be deployed"
  type = map(object({
    control_planes = optional(list(object({
      name                   = optional(string)
      node_labels            = optional(map(string), {})
      taints_enabled         = optional(bool, true)
      network_bridge         = optional(string, "vmbr0")
      mac_address            = optional(string)
      cpu_type               = optional(string, "host")
      cpu_sockets            = optional(number, 1)
      cpu_cores              = optional(number, 2)
      memory                 = optional(number, 8)
      boot_disk_size         = optional(number, 0)
      boot_disk_storage_pool = string
      data_disks = optional(list(object({
        device_name  = string
        mount_point  = string
        size         = number
        storage_pool = optional(string, "")
      })), [])
    })))
    workers = optional(list(object({
      name                   = optional(string)
      node_labels            = optional(map(string), {})
      network_bridge         = optional(string, "vmbr0")
      mac_address            = optional(string)
      cpu_type               = optional(string, "host")
      cpu_sockets            = optional(number, 1)
      cpu_cores              = optional(number, 2)
      memory                 = optional(number, 8)
      boot_disk_size         = optional(number, 0)
      boot_disk_storage_pool = string
      data_disks = optional(list(object({
        device_name  = string
        mount_point  = string
        size         = number
        storage_pool = optional(string, "")
      })), [])
    })))
  }))
}

# Proxmox API credentials
variable "proxmox_user" {
  description = "The user used for authentication with the Proxmox API"
  type        = string
}

variable "proxmox_api_token_id" {
  description = "The ID of the API token used for authentication"
  type        = string
}

variable "proxmox_api_token_secret" {
  description = "The secret value of the token used for authentication"
  type        = string
  sensitive   = true
}

variable "proxmox_api_url" {
  description = "The URL for the Proxmox API"
  type        = string
}
