variable "proxmox_nodes" {
  description = "Proxmox nodes configuration"
  type        = map(any)
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
