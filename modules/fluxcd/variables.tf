variable "git_token" {
  description = "Git token"
  sensitive   = true
  type        = string
  default     = ""
}

variable "git_org_or_username" {
  description = "Git organization"
  type        = string
  default     = ""
}

variable "git_repository" {
  description = "Git repository"
  type        = string
  default     = ""
}

variable "git_username" {
  description = "Git username"
  type        = string
  default     = ""
}

variable "fluxcd_cluster_path" {
  description = "Path to the cluster directory in the Git repository"
  type        = string
  default     = "clusters/my-cluster"
}

variable "git_base_url" {
  description = "Base URL for the Git provider"
  type        = string
  default     = "https://github.com"
}

variable "talos_k8s_cluster_domain" {
  description = "Cluster domain"
  type        = string
  default     = ""
}