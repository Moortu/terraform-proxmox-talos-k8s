variable "meta" {
  description = "Common metadata"
  type = object({
    cluster_name = string
  })
  default = null
}

variable "versions" {
  description = "Version matrix"
  type = object({
    talos      = string
    kubernetes = string
  })
  default = null
}

variable "network" {
  description = "Cluster network settings"
  type = object({
    vip_domain = string
    api_port   = number
    vip        = string
    gateway    = string
    dns_servers= list(string)
  })
  default = null
}

variable "install" {
  description = "Install settings"
  type = object({
    disk_device = string
    image_url   = string
  })
  default = null
}

variable "machine_type" {
  description = "Machine type: controlplane or worker"
  type        = string
  validation {
    condition     = contains(["controlplane", "worker"], var.machine_type)
    error_message = "machine_type must be 'controlplane' or 'worker'."
  }
}

variable "machine_secrets" {
  description = "Talos machine secrets"
  type        = any
  sensitive   = true
}

variable "cp_network" {
  description = "Control plane network info"
  type        = list(any)
  default     = []
}

variable "cilium_manifests" {
  description = "Cilium inline manifests"
  type        = string
  default     = ""
}

variable "include_cilium" {
  description = "Include Cilium inline manifests"
  type        = bool
  default     = false
}

# Legacy scalar inputs (backward compatible)
variable "talos_k8s_cluster_name" {
  type    = string
  default = "talos-cluster"
}

variable "talos_k8s_cluster_vip_domain" {
  type    = string
  default = "talos-cluster.local"
}

variable "talos_k8s_cluster_endpoint_port" {
  type    = number
  default = 6443
}

variable "talos_k8s_cluster_vip" {
  type    = string
  default = ""
}

variable "talos_version" {
  # https://github.com/siderolabs/talos/releases
  type    = string
  default = "1.11.5"
}

variable "k8s_version" {
  # https://kubernetes.io/releases/
  type    = string
  default = "1.34.2"
}

variable "talos_network_gateway" {
  type    = string
  default = "10.0.0.1"
}

variable "talos_name_servers" {
  type    = list(string)
  default = ["8.8.8.8", "1.1.1.1"]
}

variable "talos_install_disk_device" {
  type    = string
  default = "/dev/vda"
}

variable "talos_install_image_url" {
  type    = string
  default = ""
}

variable "talos_k8s_cluster_domain" {
  type    = string
  default = "cluster.local"
}

variable "talos_control_plane_vms_network" {
  type    = list(any)
  default = []
}
