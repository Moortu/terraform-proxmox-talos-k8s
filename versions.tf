variable "talos_version" {
    # https://github.com/siderolabs/talos/releases
    description = "Talos version to use"
    type        = string
    default     = "1.9.5"
    
    validation {
      condition     = can(regex("^\\d+\\.\\d+\\.\\d+$", var.talos_version))
      error_message = "The talos_version must be a valid semantic version (e.g., 1.9.5)."
    }
}

variable "k8s_version" {
    # https://www.talos.dev/v1.9/introduction/support-matrix/
    # https://kubernetes.io/releases/
    description = "Kubernetes version to use"
    type        = string
    default     = "1.31.6"
    
    validation {
      condition     = can(regex("^\\d+\\.\\d+\\.\\d+$", var.k8s_version))
      error_message = "The k8s_version must be a valid semantic version (e.g., 1.31.6)."
    }
}

variable "cilium_version" {
  # https://helm.cilium.io/
  description = "Cilium Helm version to use"
  type        = string
  default     = "1.17.2"
  
  validation {
    condition     = can(regex("^\\d+\\.\\d+\\.\\d+$", var.cilium_version))
    error_message = "The cilium_version must be a valid semantic version (e.g., 1.17.2)."
  }
}

# GitOps tool versions are defined in vars-gitops.tf

variable "metrics_server_version" {
  # https://github.com/kubernetes-sigs/metrics-server/releases
  description = "Kubernetes Metrics Server version to use"
  type        = string
  default     = "0.7.2"
}