variable "talos_version" {
    # https://github.com/siderolabs/talos/releases
    description = "Talos version to use"
    type        = string
    default     = "1.8.1"
}

variable "k8s_version" {
    # https://www.talos.dev/v1.7/introduction/support-matrix/
    description = "Kubernetes version to use"
    type        = string
    default     = "1.31.1"
}

variable "cilium_version" {
  # https://helm.cilium.io/
  description = "Cilium Helm version to use"
  type        = string
  default     = "1.16.2"
}

variable "fluxcd_version" {
  # https://github.com/argoproj/argo-cd/releases
  description = "FluxCD version to use"
  type        = string
  default     = "2.12.4"
}

variable "metrics_server_version" {
  # https://github.com/kubernetes-sigs/metrics-server/releases
  description = "Kubernetes Metrics Server version to use"
  type        = string
  default     = "0.7.2"
}