variable "kubernetes_config_path" {
  description = "Path to the kubeconfig file"
  type        = string
  default     = ""
}

variable "git_provider" {
  description = "Git provider type: 'github', 'gitlab', or 'gitea'"
  type        = string
  default     = "github"
  
  validation {
    condition     = contains(["github", "gitlab", "gitea"], var.git_provider)
    error_message = "git_provider must be one of: 'github', 'gitlab', or 'gitea'"
  }
}

variable "git_token" {
  description = "Git provider personal access token"
  type        = string
  sensitive   = true
}

variable "git_owner" {
  description = "Git repository owner/username"
  type        = string
}

variable "git_repository" {
  description = "Git repository name"
  type        = string
}

variable "git_branch" {
  description = "Git branch to use"
  type        = string
  default     = "main"
}

variable "git_url" {
  description = "Custom Git URL for Gitea or self-hosted GitLab (for GitHub, this is constructed from owner and repo)"
  type        = string
  default     = ""
}

variable "git_path" {
  description = "Path within the Git repository for configuration"
  type        = string
  default     = "clusters/default"
}

# Cilium-related variables have been removed

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

variable "wait_for_resources" {
  description = "Whether to wait for resources to be ready"
  type        = bool
  default     = true
}
