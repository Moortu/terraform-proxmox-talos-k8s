variable "talos_k8s_cluster_name" {
  description = "Name of the Talos Kubernetes cluster"
  type        = string
  default     = "talos-cluster"
}

variable "talos_k8s_cluster_domain" {
  description = "Domain name of the Talos Kubernetes cluster"
  type        = string
  default     = "talos-cluster.local"
}

variable "talos_k8s_cluster_endpoint_port" {
  description = "Port of the Kubernetes API endpoint"
  type        = number
  default     = 6443
}

variable "talos_k8s_cluster_endpoint" {
  description = "Talos k8s cluster endpoint"
  type        = string
}

variable "talos_k8s_cluster_vip" {
  description = "Virtual IP of the Talos Kubernetes cluster"
  type        = string
}

variable "talos_network_gateway" {
  description = "Gateway of the network"
  type        = string
  default     = "10.0.0.1"
}

variable "talos_network_ip_prefix" {
  description = "Network IP network prefix"
  type        = number
  default     = 24
}

variable "control_planes_network" {
  description = "Talos control plane network info"
  type = list(object({
      type = string
      node_name = string
      vm_name = string
      vm_id = string
      network_interface_name = string
      mac_address = string
      ip = string
      taints_enabled = optional(bool, true)
    }))
}

variable "workers_network" {
  description = "Talos worker network info"
  type = list(object({
      type = string
      node_name = string
      vm_name = string
      vm_id = string
      network_interface_name = string
      mac_address = string
      ip = string
    }))
}

variable "talos_machine_configuration_control_planes" {
  description = "Talos machine configuration Control planes"
  type = any
}

variable "talos_machine_configuration_workers" {
  description = "Talos machine configuration Workers"
  type = any
}

variable "talos_machine_secrets" {
  type = any
}
