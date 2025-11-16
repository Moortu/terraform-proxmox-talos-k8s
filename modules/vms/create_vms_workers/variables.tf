variable "proxmox_nodes" {
  description = "Proxmox nodes configuration"
  type        = map(any)
}

variable "worker_node_first_id" {
  type    = number
  default = 8200
}

variable "worker_node_first_ip" {
  type    = number
  default = 171
}

variable "worker_node_name_prefix" {
  type    = string
  default = "talos-worker-node"
}

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
  type = string
}

variable "talos_disk_image_locations" {
  description = "Map of node_name -> storage path for Talos disk image (e.g., local:iso/...)"
  type        = map(string)
  default     = {}
}

variable "proxmox_api_url" {
  type    = string
  default = null
}

variable "proxmox_user" {
  type    = string
  default = null
}

variable "proxmox_api_token_id" {
  type    = string
  default = null
}

variable "proxmox_api_token_secret" {
  type    = string
  default = null
}
