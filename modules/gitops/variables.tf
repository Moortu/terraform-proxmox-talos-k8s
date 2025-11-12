variable "gitops_type" {
  description = "Type of GitOps to deploy: 'flux', 'argo', or 'none'"
  type        = string
  default     = "none"
  
  validation {
    condition     = contains(["flux", "argo", "none"], var.gitops_type)
    error_message = "gitops_type must be one of: 'flux', 'argo', or 'none'"
  }
}

variable "kubernetes_config_path" {
  description = "Path to the kubeconfig file"
  type        = string
  default     = ""
}

variable "github_token" {
  description = "GitHub token for Flux"
  type        = string
  default     = ""
  sensitive   = true
}

variable "github_owner" {
  description = "GitHub owner/username for Flux repository"
  type        = string
  default     = ""
}

variable "github_repository" {
  description = "GitHub repository name for Flux"
  type        = string
  default     = ""
}

variable "github_branch" {
  description = "GitHub branch for Flux"
  type        = string
  default     = "main"
}

variable "github_path" {
  description = "Path within the GitHub repository for Flux"
  type        = string
  default     = "clusters/kalimdor"
}

variable "cilium_enabled" {
  description = "Whether to configure Cilium through GitOps"
  type        = bool
  default     = true
}

variable "cilium_version" {
  description = "Version of Cilium to deploy through GitOps"
  # https://helm.cilium.io/
  type        = string
  default     = "1.18.4"
}

variable "cilium_values" {
  description = "Values for Cilium Helm chart"
  type        = any
  default     = {}
}

variable "argocd_version" {
  description = "Version of ArgoCD to deploy"
  # https://artifacthub.io/packages/helm/argo/argo-cd
  type        = string
  default     = "5.53.12"
}

variable "argocd_namespace" {
  description = "Namespace for ArgoCD installation"
  type        = string
  default     = "argocd"
}

variable "flux_version" {
  description = "Version of Flux to deploy"
  # https://search.opentofu.org/provider/fluxcd/flux/latest
  type        = string
  default     = "2.2.3"
}

variable "flux_namespace" {
  description = "Namespace for Flux installation"
  type        = string
  default     = "flux-system"
}

variable "wait_for_resources" {
  description = "Whether to wait for resources to be ready"
  type        = bool
  default     = true
}
