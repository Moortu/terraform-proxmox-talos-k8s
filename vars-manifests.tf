variable "bootstrap_manifests" {
  description = "Bootstrap manifests from directories using Kustomize"
  type        = list(string)
  default     = ["manifests/apps"]
}

variable "metrics_server_manifest_url" {
  description = "Kubernetes Metrics Server manifest to use"
  type        = string
  # % is replaced by metrics_server_version
  default     = "https://github.com/kubernetes-sigs/metrics-server/releases/download/v%version%/components.yaml"
}
