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

variable "git_path" {
  description = "Path within the Git repository"
  type        = string
  default     = "clusters/kalimdor"
}

variable "git_url" {
  description = "Custom Git URL for Gitea or self-hosted GitLab (ignored for GitHub)"
  type        = string
  default     = ""
}

variable "cilium_enabled" {
  description = "Whether to configure Cilium through FluxCD"
  type        = bool
  default     = true
}

variable "managed_by_talos" {
  description = "Whether Cilium is currently managed by Talos inline manifests. If true, FluxCD's Cilium resources will be suspended."
  type        = bool
  default     = true
}

variable "cilium_version" {
  description = "Version of Cilium to deploy through FluxCD"
  type        = string
  default     = "1.15.6"
}

variable "cilium_values" {
  description = "Values for Cilium Helm chart"
  type        = any
  default     = {}
}

variable "flux_version" {
  description = "Version of Flux to deploy"
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
