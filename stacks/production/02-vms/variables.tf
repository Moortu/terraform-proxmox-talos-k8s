variable "proxmox_api_url" {
  description = "Proxmox API URL"
  type        = string
}

variable "proxmox_user" {
  description = "Proxmox API user"
  type        = string
}

variable "proxmox_api_token_id" {
  description = "Proxmox API token ID"
  type        = string
}

variable "proxmox_api_token_secret" {
  description = "Proxmox API token secret"
  type        = string
  sensitive   = true
}

variable "proxmox_nodes" {
  description = "Proxmox nodes configuration"
  type        = map(any)
}

variable "talos_iso_destination_filename" {
  type    = string
  default = "talos-amd64.iso"
}

variable "talos_iso_destination_storage_pool" {
  type    = string
  default = "local"
}

variable "talos_version" {
  # https://github.com/siderolabs/talos/releases
  type    = string
  default = "1.11.5"
}

variable "control_plane_first_id" {
  type    = number
  default = 8100
}

variable "control_plane_first_ip" {
  type    = number
  default = 161
}

variable "control_plane_name_prefix" {
  type    = string
  default = "talos-control-plane"
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
