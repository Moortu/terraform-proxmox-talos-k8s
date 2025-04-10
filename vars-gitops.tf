# Common GitOps settings
variable "include_cilium_inline_manifests" {
  description = "Whether to include Cilium manifests inline in the Talos configuration (set to false when GitOps takes over Cilium management)"
  type        = bool
  default     = true
}

# FluxCD Deployment Control
variable "deploy_fluxcd" {
  description = "Whether to deploy FluxCD"
  type        = bool
  default     = false
}

# FluxCD Git Provider Configuration
variable "fluxcd_git_provider" {
  description = "Git provider for FluxCD: 'github', 'gitlab', or 'gitea'"
  type        = string
  default     = "github"
  
  validation {
    condition     = contains(["github", "gitlab", "gitea"], var.fluxcd_git_provider)
    error_message = "fluxcd_git_provider must be one of: 'github', 'gitlab', or 'gitea'"
  }
}

variable "fluxcd_git_token" {
  description = "Git provider token for FluxCD authentication"
  type        = string
  default     = ""
  sensitive   = true
}

variable "fluxcd_git_owner" {
  description = "Git repository owner/username for FluxCD"
  type        = string
  default     = ""
}

variable "fluxcd_git_repository" {
  description = "Git repository name for FluxCD"
  type        = string
  default     = ""
}

variable "fluxcd_git_branch" {
  description = "Git branch for FluxCD"
  type        = string
  default     = "main"
}

variable "fluxcd_git_path" {
  description = "Path within the Git repository for FluxCD"
  type        = string
  default     = "clusters/kalimdor"
}

variable "fluxcd_git_url" {
  description = "Custom Git URL for Gitea or self-hosted GitLab (ignored for GitHub)"
  type        = string
  default     = ""
}

# FluxCD Cilium Configuration
variable "fluxcd_cilium_enabled" {
  description = "Whether to configure Cilium through FluxCD"
  type        = bool
  default     = true
}

# FluxCD Version Configuration
variable "fluxcd_version" {
  description = "Version of Flux to deploy"
  type        = string
  default     = "2.2.3"
}

variable "fluxcd_namespace" {
  description = "Namespace for Flux installation"
  type        = string
  default     = "flux-system"
}

variable "fluxcd_wait_for_resources" {
  description = "Whether to wait for resources to be ready"
  type        = bool
  default     = true
}

# ArgoCD Deployment Control
variable "deploy_argocd" {
  description = "Whether to deploy ArgoCD"
  type        = bool
  default     = false
}

# ArgoCD Git Provider Configuration
variable "argocd_git_provider" {
  description = "Git provider for ArgoCD: 'github', 'gitlab', or 'gitea'"
  type        = string
  default     = "github"
  
  validation {
    condition     = contains(["github", "gitlab", "gitea"], var.argocd_git_provider)
    error_message = "argocd_git_provider must be one of: 'github', 'gitlab', or 'gitea'"
  }
}

variable "argocd_git_token" {
  description = "Git provider token for ArgoCD authentication"
  type        = string
  default     = ""
  sensitive   = true
}

variable "argocd_git_owner" {
  description = "Git repository owner/username for ArgoCD"
  type        = string
  default     = ""
}

variable "argocd_git_repository" {
  description = "Git repository name for ArgoCD"
  type        = string
  default     = ""
}

variable "argocd_git_branch" {
  description = "Git branch for ArgoCD"
  type        = string
  default     = "main"
}

variable "argocd_git_url" {
  description = "Custom Git URL for Gitea or self-hosted GitLab (for GitHub, this is constructed from owner and repo)"
  type        = string
  default     = ""
}

# ArgoCD Cilium Configuration
variable "argocd_cilium_enabled" {
  description = "Whether to configure Cilium through ArgoCD"
  type        = bool
  default     = true
}

# ArgoCD Version Configuration
variable "argocd_version" {
  description = "Version of Argo CD to deploy"
  type        = string
  default     = "5.53.12"
}

variable "argocd_namespace" {
  description = "Namespace for Argo CD installation"
  type        = string
  default     = "argocd"
}

variable "argocd_admin_password" {
  description = "Admin password for Argo CD (if empty, a random one will be generated)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "argocd_wait_for_resources" {
  description = "Whether to wait for resources to be ready"
  type        = bool
  default     = true
}

variable "gitops_include_cilium_in_talos" {
  description = "Whether to include Cilium manifests in Talos configuration (set to false when GitOps takes over Cilium management)"
  type        = bool
  default     = true
}

variable "gitops_argocd_version" {
  description = "Version of ArgoCD to deploy (if gitops_type is 'argo')"
  type        = string
  default     = "5.51.4" # Corresponds to ArgoCD v2.9.5
}

variable "gitops_argocd_namespace" {
  description = "Namespace for ArgoCD installation (if gitops_type is 'argo')"
  type        = string
  default     = "argocd"
}

variable "gitops_flux_version" {
  description = "Version of Flux to deploy (if gitops_type is 'flux')"
  type        = string
  default     = "2.2.3"
}

variable "gitops_flux_namespace" {
  description = "Namespace for Flux installation (if gitops_type is 'flux')"
  type        = string
  default     = "flux-system"
}
