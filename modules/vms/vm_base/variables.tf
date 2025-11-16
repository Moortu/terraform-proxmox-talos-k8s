variable "meta" {
  description = "Common metadata"
  type = object({
    environment  = string
    project      = string
    cluster_name = string
    name_prefix  = string
    tags         = map(string)
  })
  default = null
}

variable "vm_specs" {
  description = "VM specifications"
  type = object({
    name_prefix = string
    first_id    = number
    first_ip    = number
    count       = number
  })
}

variable "network" {
  description = "Network settings"
  type = object({
    dhcp    = bool
    cidr    = string
    gateway = string
  })
}

variable "iso" {
  description = "ISO settings"
  type = object({
    image_location = string
  })
}

variable "proxmox_nodes" {
  description = "Proxmox nodes configuration"
  type        = map(any)
}

variable "vm_configs" {
  description = "Per-VM configuration from proxmox_nodes"
  type        = list(any)
}

variable "vm_type" {
  description = "VM type: control_plane or worker"
  type        = string
  validation {
    condition     = contains(["control_plane", "worker"], var.vm_type)
    error_message = "vm_type must be 'control_plane' or 'worker'."
  }
}

# Legacy scalar inputs (backward compatible)
variable "talos_network_dhcp" {
  type    = bool
  default = true
}

variable "talos_network_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "talos_network_gateway" {
  type    = string
  default = "10.0.0.1"
}

variable "talos_iso_image_location" {
  type    = string
  default = null
}

variable "disk_image_locations" {
  description = "Map of node_name -> storage path of the Talos disk image (e.g. local:iso/...)"
  type        = map(string)
  default     = {}
}

variable "proxmox_api_url" {
  description = "Proxmox API URL"
  type        = string
  default     = null
}

variable "proxmox_user" {
  description = "Proxmox API user"
  type        = string
  default     = null
}

variable "proxmox_api_token_id" {
  description = "Proxmox API token ID"
  type        = string
  default     = null
}

variable "proxmox_api_token_secret" {
  description = "Proxmox API token secret"
  type        = string
  default     = null
}
