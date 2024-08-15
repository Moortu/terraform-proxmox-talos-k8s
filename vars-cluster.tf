variable "talos_k8s_cluster_name" {
  description = "Name of the Talos Kubernetes cluster"
  type        = string
  default     = "talos-cluster"
}

variable "talos_k8s_cluster_vip" {
  description = "Virtual IP of the Talos Kubernetes cluster"
  type        = string
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

variable "control_plane_first_ip" {
  description = "First ip of a control-plane"
  type        = number
  default     = 161
}

variable "worker_node_first_ip" {
  description = "First ip of a worker node"
  type        = number
  default     = 171
}

variable "install_disk_device" {
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
  default     = 8101
}

variable "worker_node_first_id" {
  description = "First id of a worker node"
  type        = number
  default     = 8201
}