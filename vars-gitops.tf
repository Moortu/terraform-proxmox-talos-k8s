#######################################################################
# KUBERNETES CONFIGURATION
#######################################################################
variable "kubernetes_config_path" {
  description = "Path to the Kubernetes configuration file"
  type        = string
  default     = ""
}

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

# For backward compatibility with existing code - these are still used in main.tf
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
# UPDATED FLUXCD GIT CONFIGURATION
#######################################################################
variable "git_base_url" {
  description = "Base URL for the Git provider (e.g., https://github.com)"
  type        = string
  default     = "https://github.com"
}

variable "git_token" {
  description = "Git provider personal access token for authentication"
  type        = string
  default     = ""
  sensitive   = true
}

variable "git_org_or_username" {
  description = "Git organization or username"
  type        = string
  default     = ""
}

variable "git_repository" {
  description = "Git repository name"
  type        = string
  default     = "fluxcd_repo"
}

variable "git_username" {
  description = "Git username for authentication"
  type        = string
  default     = ""
}

#######################################################################
# UPDATED ARGOCD GIT CONFIGURATION 
#######################################################################
variable "argocd_base_url" {
  description = "Base URL for ArgoCD's Git provider (e.g., https://github.com)"
  type        = string
  default     = "https://github.com"
}

variable "argocd_token" {
  description = "Git provider personal access token for ArgoCD authentication"
  type        = string
  default     = ""
  sensitive   = true
}

variable "argocd_org_or_username" {
  description = "Git organization or username for ArgoCD"
  type        = string
  default     = ""
}

variable "argocd_repository" {
  description = "Git repository name for ArgoCD"
  type        = string
  default     = "argocd_repo"
}

variable "argocd_username" {
  description = "Git username for ArgoCD authentication"
  type        = string
  default     = ""
}

variable "argocd_cluster_path" {
  description = "Path within the Git repository for ArgoCD"
  type        = string
  default     = "clusters/default"
}

# ArgoCD variables kept for compatibility
variable "argocd_git_provider" {
  description = "Git provider for ArgoCD"
  type        = string
  default     = "github"
  
  validation {
    condition     = contains(["github", "gitlab", "gitea"], var.argocd_git_provider)
    error_message = "argocd_git_provider must be one of: 'github', 'gitlab', or 'gitea'"
  }
}

variable "argocd_git_token" {
  description = "Git provider token for ArgoCD"
  type        = string
  default     = ""
  sensitive   = true
}

variable "argocd_git_owner" {
  description = "Git repository owner/username for ArgoCD"
  type        = string
  default     = ""
}

variable "argocd_git_url" {
  description = "Custom Git URL for ArgoCD"
  type        = string
  default     = ""
}

#######################################################################
# FLUXCD REPOSITORY CONFIGURATION
#######################################################################
variable "fluxcd_cluster_path" {
  description = "Path to the cluster configuration in the Git repository"
  type        = string
  default     = "clusters/my-cluster"
}

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
# CILIUM IS ALWAYS DEPLOYED VIA INLINE MANIFESTS
#######################################################################
# Cilium is always managed via inline manifests in the Talos configuration
# The include_cilium_inline_manifests variable is defined in vars-manifests.tf

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
