variable "worker_node_first_id" {
  description = "First id of a worker node"
  type        = number
  default     = 8201
}

variable "worker_node_first_ip" {
  description = "First ip of a worker node"
  type        = number
  default     = 171
}

variable "network_dhcp" {
  description = "If dhcp is enabled and configured"
  type        = bool
  default     = true
}

variable "network_cidr" {
  description = "Network address in CIDR notation"
  type        = string
  default     = "10.0.0.0/16"
}

variable "network_gateway" {
  description = "Gateway of the network"
  type        = string
  default     = "10.0.0.1"
}

variable "talos_version" {
    # https://github.com/siderolabs/talos/releases
    description = "Talos version to use"
    type        = string
    default     = "1.8.0"
}

variable "talos_iso_image_location" {
  description = "talos iso image location"
}

variable "worker_node_name_prefix" {
  description = "Name prefix used in both VM name and hostname, for a worker node"
  type        = string
  default     = "talos-worker-node"
}

variable "proxmox_nodes" {
  description = "Proxmox servers on which the talos cluster will be deployed"
  type = map(object({
    control_planes = optional(list(object({
      name = string
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

    workers = optional(list(object({
      name = string
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