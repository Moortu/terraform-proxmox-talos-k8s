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

variable "talos_k8s_cluster_name" {
  description = "Name of the Talos Kubernetes cluster"
  type        = string
  default     = "talos-cluster"
}

variable "talos_k8s_cluster_vip" {
  description = "Virtual IP of the Talos Kubernetes cluster"
  type        = string
}

variable "talos_k8s_cluster_vip_domain" {
  description = "Domain name of the Talos Kubernetes vip endpoint, if you don't have a domain name set, then it's the vip ip"
  type        = string
}

variable "talos_version" {
    # https://github.com/siderolabs/talos/releases
    description = "Talos version to use"
    type        = string
    default     = "1.8.0"
}

variable "talos_network_gateway" {
  description = "Gateway of the network"
  type        = string
  default     = "10.0.0.1"
}

variable "talos_name_servers" {
  description = "List of DNS nameservers to use for the Talos nodes"
  type        = list(string)
  default     = ["8.8.8.8", "1.1.1.1"]
}

variable "k8s_version" {
    # https://www.talos.dev/v1.7/introduction/support-matrix/
    description = "Kubernetes version to use"
    type        = string
    default     = "1.31.1"
}

variable "talos_install_disk_device" {
  description = "Disk to install Talos on"
  type        = string
  default     = "/dev/vda"
}

variable "talos_install_image_url" {
  description = "Disk to install Talos on"
  type        = string
  default     = "/dev/vda"
}

variable "talos_control_plane_vms_network" {
  description = "network information of the control plane vms"
  type = list(object({
    type                   = string
    node_name              = string
    vm_name                = string
    vm_id                  = number
    network_interface_name = string
    mac_address            = string
    ip                     = string
  }))
}

variable "cilium_manifests" {
  description = "The generated Cilium manifests to include in the Talos configuration"
  type        = string
}

variable "include_cilium_inline_manifests" {
  description = "Whether to include Cilium manifests inline in the Talos configuration (set to false when GitOps takes over Cilium management)"
  type        = bool
  default     = true
}