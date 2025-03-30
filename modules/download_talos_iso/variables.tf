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

variable "talos_version" {
    # https://github.com/siderolabs/talos/releases
    description = "Talos version to use"
    type        = string
    default     = "1.8.0"
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