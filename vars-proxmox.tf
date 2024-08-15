variable "proxmox_user" {
  description = "The user used for authentication with the Proxmox API, example: newuser@pve"
  type        = string
}

variable "proxmox_api_token_id" {
  description = "The ID of the API token used for authentication with the Proxmox API."
  type        = string
}

variable "proxmox_api_token_secret" {
  description = "The secret value of the token used for authentication with the Proxmox API."
  type        = string
}

variable "proxmox_api_url" {
  description = "The URL for the Proxmox API."
  type        = string
}

variable "proxmox_servers" {
  description = "Proxmox servers on which the talos cluster will be deployed"
  type        = map(object({
    # Number of control plane nodes to deploy on the server
    control_planes_count = optional(number, 1)
    # The name of the storage pool where virtual hard disks will be stored
    disk_storage_pool    = string
    # The name of the network bridge on the Proxmox host
    network_bridge       = optional(string, "vmbr0")
    # Additional kubernetes node labels to add to the nodes deployed on this server
    node_labels          = optional(map(string), {})
  }))
}