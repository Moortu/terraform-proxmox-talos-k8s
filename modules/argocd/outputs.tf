output "namespace" {
  description = "The namespace where ArgoCD is installed"
  value       = var.argocd_namespace
}

output "git_repository" {
  description = "The Git repository where ArgoCD configurations are stored"
  value       = var.git_repository
}

output "is_ready" {
  description = "Indicates whether ArgoCD has been successfully installed"
  value       = helm_release.argocd.status == "deployed"
}

output "admin_password" {
  description = "The ArgoCD admin password (only if auto-generated)"
  value       = local.need_random_password ? random_password.argocd_admin[0].result : "Password was provided by user and is not shown here"
  sensitive   = true
}

output "argocd_version" {
  description = "The version of ArgoCD that was deployed"
  value       = var.argocd_version
}

# Cilium output has been removed
