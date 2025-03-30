variable "talos_version" {
    # https://github.com/siderolabs/talos/releases
    description = "Talos version to use"
    type        = string
    default     = "1.9.5"
}

variable "k8s_version" {
    # https://www.talos.dev/v1.9/introduction/support-matrix/
    # https://kubernetes.io/releases/
    description = "Kubernetes version to use"
    type        = string
    default     = "1.31.6"
}

variable "cilium_version" {
  # https://helm.cilium.io/
  description = "Cilium Helm version to use"
  type        = string
  default     = "1.17.2"
}

variable "fluxcd_version" {
  # https://github.com/fluxcd/flux2/releases
  description = "FluxCD version to use"
  type        = string
  default     = "2.5.1"
}

variable "argocd_version" {
  # https://github.com/argoproj/argo-cd/releases
  description = "ArgoCD version to use"
  type        = string
  default     = "2.14.8"
}

variable "metrics_server_version" {
  # https://github.com/kubernetes-sigs/metrics-server/releases
  description = "Kubernetes Metrics Server version to use"
  type        = string
  default     = "0.7.2"
}