# Generate the complex proxmox_nodes variable definition
# This ensures consistency across stacks that use this variable
generate_hcl "_generated_proxmox_nodes_var.tm.tf" {
  content {
    variable "proxmox_nodes" {
      description = "Proxmox servers on which the talos cluster will be deployed"
      type = tm_hcl_expression(<<-EOT
        map(object({
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
      EOT
      )
    }
  }
}
