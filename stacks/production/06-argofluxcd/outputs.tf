output "fluxcd_deployed" {
  description = "Whether FluxCD was deployed"
  value       = var.deploy_fluxcd
}

output "argocd_deployed" {
  description = "Whether ArgoCD was deployed"
  value       = var.deploy_argocd
}
