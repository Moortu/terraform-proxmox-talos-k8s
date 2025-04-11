# IP prefix is now derived from CIDR notation

variable "talos_network_cidr" {
  description = "Network address in CIDR notation"
  type        = string
  default     = "192.168.1.0/24"
  
  validation {
    condition     = can(cidrnetmask(var.talos_network_cidr))
    error_message = "The talos_network_cidr value must be a valid CIDR notation (e.g., 10.0.10.0/24)."
  }
}

variable "talos_network_gateway" {
  description = "Gateway of the network"
  type        = string
  default     = "192.168.1.1"
  
  validation {
    condition     = can(regex("^([0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3})$", var.talos_network_gateway))
    error_message = "The talos_network_gateway value must be a valid IPv4 address (e.g., 10.0.0.1)."
  }
}

variable "talos_network_dhcp" {
  description = "If dhcp is enabled and configured"
  type        = bool
  default     = true
}

variable "talos_network_ip_prefix_override" {
  description = "Override the network prefix derived from CIDR (e.g., use 8 for a /8 subnet mask while keeping IPs in the original CIDR range)"
  type        = number
  default     = null
}

variable "talos_name_servers" {
  description = "List of DNS nameservers to use for the Talos nodes"
  type        = list(string)
  default     = ["8.8.8.8", "1.1.1.1"]
}


variable "use_kube_proxy" {
  type    = bool
  default = false
}