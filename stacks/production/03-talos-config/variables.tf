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
  type = string
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
  type        = string
  default     = ""
  description = "URL of the Talos installer image. If not provided, it will be read from the 01-talos-iso stack's outputs."
}

variable "talos_k8s_cluster_domain" {
  type    = string
  default = "cluster.local"
}

variable "cilium_version" {
  # https://helm.cilium.io/
  type    = string
  default = "1.18.4"
}

variable "use_kube_proxy" {
  type    = bool
  default = false
}

variable "include_cilium_inline_manifests" {
  type    = bool
  default = true
}
