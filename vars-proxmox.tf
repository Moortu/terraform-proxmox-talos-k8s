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

variable "proxmox_nodes" {
  description = "Proxmox servers on which the talos cluster will be deployed"
  type = map(object({
    control_planes = optional(list(object({
      name = optional(string)
      # Additional kubernetes node labels to add to the worker node(s)
      node_labels = optional(map(string), {})
      # Whether to taint the control plane node to prevent workloads from running on it
      taints_enabled = optional(bool, true)
      # The name of the network bridge on the Proxmox host
      network_bridge = optional(string, "vmbr0")
      # Predefined mac address to be used by the vm
      mac_address = optional(string)
      # The type of the CPU
      cpu_type = optional(string, "host")
      # The amount of sockets to give the control plane 
      cpu_sockets = optional(number, 1)
      # The amount of CPU cores to give the worker node(s)
      cpu_cores = optional(number, 2)
      # The amount of memory in GiB to give the worker node(s)
      memory = optional(number, 8)
      # The size of the boot disk in GiB to give the worker node(s)
      boot_disk_size = optional(number, 0)
      # The name of the storage pool where virtual hard disks will be stored
      boot_disk_storage_pool = string
      data_disks = optional(list(object({
        device_name = string
        mount_point = string
        # The size of the data disk in GiB per worker node
        size = number
        # The name of the storage pool where the disk be stored
        storage_pool = optional(string, "")
      })), [])
    })))

    workers = optional(list(object({
      name = optional(string)
      # Additional kubernetes node labels to add to the worker node(s)
      node_labels = optional(map(string), {})
      # The name of the network bridge on the Proxmox host
      network_bridge = optional(string, "vmbr0")
      # Predefined mac address to be used by the vm
      mac_address = optional(string)
      # The type of the CPU
      cpu_type = optional(string, "host")
      # The amount of sockets to give the control plane 
      cpu_sockets = optional(number, 1)
      # The amount of CPU cores to give the worker node(s)
      cpu_cores = optional(number, 2)
      # The amount of memory in GiB to give the worker node(s)
      memory = optional(number, 8)
      # The size of the boot disk in GiB to give the worker node(s)
      boot_disk_size = optional(number, 0)
      # The name of the storage pool where virtual hard disks will be stored
      boot_disk_storage_pool = string
      data_disks = optional(list(object({
        device_name = string
        mount_point = string
        # The size of the data disk in GiB per worker node
        size = number
        # The name of the storage pool where the disk be stored
        storage_pool = optional(string, "")
      })), [])
    })))

  }))
}

