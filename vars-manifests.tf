variable "bootstrap_manifests" {
  description = "Bootstrap manifests from directories using Kustomize"
  type        = list(string)
  default     = ["manifests/apps"]
}

variable "argocd_manifest_url" {
  description = "ArgoCD manifest to use"
  type        = string
  # % is replaced by metrics_server_version
  default     = "https://raw.githubusercontent.com/argoproj/argo-cd/v%version%/manifests/ha/install.yaml"
}

variable "metrics_server_manifest_url" {
  description = "Kubernetes Metrics Server manifest to use"
  type        = string
  # % is replaced by metrics_server_version
  default     = "https://github.com/kubernetes-sigs/metrics-server/releases/download/v%version%/components.yaml"
}
