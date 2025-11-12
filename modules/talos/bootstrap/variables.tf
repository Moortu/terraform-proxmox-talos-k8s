variable "client_configuration" {
  description = "Talos client configuration"
  type        = any
  sensitive   = true
}

variable "cluster_name" {
  description = "Cluster name"
  type        = string
}

variable "control_plane_nodes" {
  description = "Control plane nodes network info"
  type = list(object({
    ip = string
  }))
}

variable "bootstrap_wait_duration" {
  description = "Duration to wait after bootstrap"
  type        = string
  default     = "120s"
}
