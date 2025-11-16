# ============================================================================
# FluxCD Configuration
# ============================================================================

variable "deploy_fluxcd" {
  description = "Deploy FluxCD to the cluster"
  type        = bool
  default     = false
}

variable "git_base_url" {
  description = "Git base URL (e.g., https://github.com)"
  type        = string
  default     = "https://github.com"
}

variable "git_org_or_username" {
  description = "Git organization or username"
  type        = string
}

variable "git_repository" {
  description = "Git repository name"
  type        = string
}

variable "git_username" {
  description = "Git username for authentication"
  type        = string
}

variable "git_token" {
  description = "Git token for authentication"
  type        = string
  sensitive   = true
}

variable "git_url" {
  description = "Full git URL (auto-constructed from base_url/org/repo)"
  type        = string
  default     = ""
}

variable "fluxcd_cluster_path" {
  description = "Path in git repo for cluster manifests"
  type        = string
  default     = "clusters/production"
}

variable "talos_k8s_cluster_domain" {
  description = "Kubernetes cluster domain"
  type        = string
  default     = "cluster.local"
}

# ============================================================================
# ArgoCD Configuration
# ============================================================================

variable "deploy_argocd" {
  description = "Deploy ArgoCD to the cluster"
  type        = bool
  default     = false
}

variable "argocd_namespace" {
  description = "Namespace for ArgoCD"
  type        = string
  default     = "argocd"
}

variable "argocd_version" {
  description = "ArgoCD Helm chart version"
  type        = string
  default     = "5.51.6"
}
