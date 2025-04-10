output "gitops_type" {
  description = "The type of GitOps deployed (flux, argo, or none)"
  value       = var.gitops_type
}

output "argocd_namespace" {
  description = "The namespace where ArgoCD is installed"
  value       = var.gitops_type == "argo" ? var.argocd_namespace : ""
}

output "flux_namespace" {
  description = "The namespace where Flux is installed"
  value       = var.gitops_type == "flux" ? var.flux_namespace : ""
}

output "cilium_managed_by_gitops" {
  description = "Whether Cilium is managed by GitOps"
  value       = var.gitops_type != "none" && var.cilium_enabled
}

output "flux_github_repository" {
  description = "The GitHub repository used for Flux"
  value       = var.gitops_type == "flux" ? "https://github.com/${var.github_owner}/${var.github_repository}" : ""
}

output "flux_path" {
  description = "The path in the GitHub repository where Flux resources are stored"
  value       = var.gitops_type == "flux" ? var.github_path : ""
}

output "argocd_server_url" {
  description = "URL to access the ArgoCD server"
  value       = var.gitops_type == "argo" ? "https://argocd.${var.argocd_namespace}.svc:443" : ""
}
