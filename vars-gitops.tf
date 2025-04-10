#######################################################################
# COMMON GITOPS SETTINGS
#######################################################################
# GitOps Deployment Control
variable "deploy_gitops" {
  description = "Controls which GitOps tool(s) to deploy: 'none', 'flux', 'argo', or 'both'"
  type        = string
  default     = "flux"
  
  validation {
    condition     = contains(["none", "flux", "argo", "both"], var.deploy_gitops)
    error_message = "deploy_gitops must be one of: 'none', 'flux', 'argo', or 'both'"
  }
}

# For backward compatibility with existing code
variable "deploy_fluxcd" {
  description = "Whether to deploy FluxCD (deprecated, use deploy_gitops instead)"
  type        = bool
  default     = false
}

variable "deploy_argocd" {
  description = "Whether to deploy ArgoCD (deprecated, use deploy_gitops instead)"
  type        = bool
  default     = false
}

#######################################################################
# COMMON GIT PROVIDER CONFIGURATION
#######################################################################
variable "gitops_git_provider" {
  description = "Git provider for GitOps: 'github', 'gitlab', or 'gitea'"
  type        = string
  default     = "github"
  
  validation {
    condition     = contains(["github", "gitlab", "gitea"], var.gitops_git_provider)
    error_message = "gitops_git_provider must be one of: 'github', 'gitlab', or 'gitea'"
  }
}

variable "gitops_git_token" {
  description = "Git provider token for GitOps authentication"
  type        = string
  default     = ""
  sensitive   = true
}

variable "gitops_git_owner" {
  description = "Git repository owner/username"
  type        = string
  default     = ""
}

variable "gitops_git_url" {
  description = "Custom Git URL for Gitea or self-hosted GitLab (ignored for GitHub)"
  type        = string
  default     = ""
}

# For backward compatibility with existing code
variable "fluxcd_git_provider" {
  description = "Git provider for FluxCD (deprecated, use gitops_git_provider instead)"
  type        = string
  default     = "github"
  
  validation {
    condition     = contains(["github", "gitlab", "gitea"], var.fluxcd_git_provider)
    error_message = "fluxcd_git_provider must be one of: 'github', 'gitlab', or 'gitea'"
  }
}

variable "fluxcd_git_token" {
  description = "Git provider token for FluxCD (deprecated, use gitops_git_token instead)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "fluxcd_git_owner" {
  description = "Git repository owner/username for FluxCD (deprecated, use gitops_git_owner instead)"
  type        = string
  default     = ""
}

variable "fluxcd_git_url" {
  description = "Custom Git URL for FluxCD (deprecated, use gitops_git_url instead)"
  type        = string
  default     = ""
}

variable "argocd_git_provider" {
  description = "Git provider for ArgoCD (deprecated, use gitops_git_provider instead)"
  type        = string
  default     = "github"
  
  validation {
    condition     = contains(["github", "gitlab", "gitea"], var.argocd_git_provider)
    error_message = "argocd_git_provider must be one of: 'github', 'gitlab', or 'gitea'"
  }
}

variable "argocd_git_token" {
  description = "Git provider token for ArgoCD (deprecated, use gitops_git_token instead)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "argocd_git_owner" {
  description = "Git repository owner/username for ArgoCD (deprecated, use gitops_git_owner instead)"
  type        = string
  default     = ""
}

variable "argocd_git_url" {
  description = "Custom Git URL for ArgoCD (deprecated, use gitops_git_url instead)"
  type        = string
  default     = ""
}

#######################################################################
# FLUXCD REPOSITORY CONFIGURATION
#######################################################################
variable "fluxcd_repository_name" {
  description = "Git repository name for FluxCD"
  type        = string
  default     = "fluxcd_repo"
}

variable "fluxcd_branch" {
  description = "Git branch for FluxCD"
  type        = string
  default     = "main"
}

variable "fluxcd_path" {
  description = "Path within the Git repository for FluxCD"
  type        = string
  default     = "clusters/default"
}

# For backward compatibility with existing code
variable "fluxcd_git_repository" {
  description = "Git repository name for FluxCD (deprecated, use fluxcd_repository_name instead)"
  type        = string
  default     = ""
}

variable "fluxcd_git_branch" {
  description = "Git branch for FluxCD (deprecated, use fluxcd_branch instead)"
  type        = string
  default     = "main"
}

variable "fluxcd_git_path" {
  description = "Path within the Git repository for FluxCD (deprecated, use fluxcd_path instead)"
  type        = string
  default     = "clusters/kalimdor"
}

#######################################################################
# ARGOCD REPOSITORY CONFIGURATION
#######################################################################
variable "argocd_repository_name" {
  description = "Git repository name for ArgoCD"
  type        = string
  default     = "argocd_repo"
}

variable "argocd_branch" {
  description = "Git branch for ArgoCD"
  type        = string
  default     = "main"
}

# For backward compatibility with existing code
variable "argocd_git_repository" {
  description = "Git repository name for ArgoCD (deprecated, use argocd_repository_name instead)"
  type        = string
  default     = ""
}

variable "argocd_git_branch" {
  description = "Git branch for ArgoCD (deprecated, use argocd_branch instead)"
  type        = string
  default     = "main"
}

#######################################################################
# CILIUM MANAGEMENT CONFIGURATION
#######################################################################
variable "include_cilium_inline_manifests" {
  description = "DEPRECATED: This variable is no longer used and will be removed in a future release. Use cilium_management='inline' instead."
  type        = bool
  default     = true
}

variable "cilium_management" {
  description = "Which tool should manage Cilium: 'inline', 'flux', 'argo', or 'both'"
  type        = string
  default     = "inline"
  
  validation {
    condition     = contains(["inline", "flux", "argo", "both"], var.cilium_management)
    error_message = "cilium_management must be one of: 'inline', 'flux', 'argo', or 'both'"
  }
}

# For backward compatibility with existing code
variable "fluxcd_cilium_enabled" {
  description = "Whether to configure Cilium through FluxCD (deprecated, use cilium_management instead)"
  type        = bool
  default     = true
}

variable "argocd_cilium_enabled" {
  description = "Whether to configure Cilium through ArgoCD (deprecated, use cilium_management instead)"
  type        = bool
  default     = true
}

variable "gitops_include_cilium_in_talos" {
  description = "Whether to include Cilium manifests in Talos configuration (deprecated, use include_cilium_inline_manifests instead)"
  type        = bool
  default     = true
}

#######################################################################
# FLUXCD CONFIGURATION
#######################################################################
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

# For backward compatibility with existing code
variable "gitops_flux_version" {
  description = "Version of Flux to deploy (deprecated, use fluxcd_version instead)"
  type        = string
  default     = "2.2.3"
}

variable "gitops_flux_namespace" {
  description = "Namespace for Flux installation (deprecated, use fluxcd_namespace instead)"
  type        = string
  default     = "flux-system"
}

#######################################################################
# ARGOCD CONFIGURATION
#######################################################################
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

# For backward compatibility with existing code
variable "gitops_argocd_version" {
  description = "Version of ArgoCD to deploy (deprecated, use argocd_version instead)"
  type        = string
  default     = "5.51.4"
}

variable "gitops_argocd_namespace" {
  description = "Namespace for ArgoCD installation (deprecated, use argocd_namespace instead)"
  type        = string
  default     = "argocd"
}

#######################################################################
# COMMON WAIT FOR RESOURCES CONFIGURATION
#######################################################################
variable "gitops_wait_for_resources" {
  description = "Whether to wait for GitOps resources to be ready"
  type        = bool
  default     = true
}

# For backward compatibility with existing code
variable "fluxcd_wait_for_resources" {
  description = "Whether to wait for FluxCD resources to be ready (deprecated, use gitops_wait_for_resources instead)"
  type        = bool
  default     = true
}

variable "argocd_wait_for_resources" {
  description = "Whether to wait for ArgoCD resources to be ready (deprecated, use gitops_wait_for_resources instead)"
  type        = bool
  default     = true
}
