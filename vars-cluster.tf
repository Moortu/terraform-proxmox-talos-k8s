variable "talos_k8s_cluster_name" {
  description = "Name of the Talos Kubernetes cluster"
  type        = string
  default     = "talos-cluster"
}

variable "talos_k8s_cluster_vip" {
  description = "Virtual IP of the Talos Kubernetes cluster"
  type        = string
  
  validation {
    condition     = can(regex("^([0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3})$", var.talos_k8s_cluster_vip))
    error_message = "The talos_k8s_cluster_vip value must be a valid IPv4 address (e.g., 10.0.10.1)."
  }
}

variable "talos_k8s_cluster_vip_domain" {
description = "Domain name of the Talos Kubernetes vip endpoint, if you don't have a domain name set, then it's the vip ip"
  type        = string  
}

variable "talos_k8s_cluster_domain" {
  description = "Domain name of the Internal Talos Kubernetes cluster"
  type        = string
  default     = "cluster.local"
  
  validation {
    condition     = can(regex("^[a-z0-9]([a-z0-9-]*[a-z0-9])?(\\.[a-z0-9]([a-z0-9-]*[a-z0-9])?)*$", var.talos_k8s_cluster_domain))
    error_message = "The talos_k8s_cluster_domain must be a valid domain name."
  }
}

variable "talos_k8s_cluster_endpoint_port" {
  description = "Port of the Kubernetes API endpoint"
  type        = number
  default     = 6443
}

variable "control_plane_first_ip" {
  description = "First ip of a control-plane"
  type        = number
  default     = 161
  
  validation {
    condition     = var.control_plane_first_ip > 1 && var.control_plane_first_ip < 254
    error_message = "The control_plane_first_ip must be between 2 and 253 to allow for valid IP addresses."
  }
}

variable "worker_node_first_ip" {
  description = "First ip of a worker node"
  type        = number
  default     = 171
  
  validation {
    condition     = var.worker_node_first_ip > 1 && var.worker_node_first_ip < 254
    error_message = "The worker_node_first_ip must be between 2 and 253 to allow for valid IP addresses."
  }
}

variable "talos_install_disk_device" {
  description = "Disk to install Talos on"
  type        = string
  default     = "/dev/vda"
}

variable "control_plane_name_prefix" {
  description = "Name prefix used in both VM name and hostname, for a control-plane"
  type        = string
  default     = "talos-control-plane"
}

variable "worker_node_name_prefix" {
  description = "Name prefix used in both VM name and hostname, for a worker node"
  type        = string
  default     = "talos-worker-node"
}

variable "control_plane_first_id" {
  description = "First id of a control-plane"
  type        = number
  default     = 8100
}

variable "worker_node_first_id" {
  description = "First id of a worker node"
  type        = number
  default     = 8200
}