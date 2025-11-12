variable "machine_configuration" {
  description = "Talos machine configuration"
  type        = any
}

variable "client_configuration" {
  description = "Talos client configuration"
  type        = any
  sensitive   = true
}

variable "nodes_network" {
  description = "Nodes network information"
  type = list(object({
    type                   = string
    node_name              = string
    vm_name                = string
    vm_id                  = number
    network_interface_name = string
    mac_address            = string
    ip                     = string
    taints_enabled         = optional(bool, true)
  }))
}

variable "cluster_domain" {
  description = "Cluster domain"
  type        = string
  default     = "cluster.local"
}

variable "cluster_endpoint" {
  description = "Cluster endpoint"
  type        = string
}

variable "network_gateway" {
  description = "Network gateway"
  type        = string
  default     = "10.0.0.1"
}

variable "network_ip_prefix" {
  description = "Network IP prefix"
  type        = number
  default     = 24
}

variable "cluster_vip" {
  description = "Cluster VIP"
  type        = string
}

variable "config_template_path" {
  description = "Path to config template"
  type        = string
  default     = "modules/talos-config-templates"
}
