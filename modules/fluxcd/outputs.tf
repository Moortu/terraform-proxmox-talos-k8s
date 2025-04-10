output "namespace" {
  description = "The namespace where Flux is installed"
  value       = var.flux_namespace
}

output "git_repository" {
  description = "The Git repository where Flux configurations are stored"
  value       = var.git_repository
}

output "is_ready" {
  description = "Indicates whether Flux has been successfully bootstrapped"
  value       = null_resource.flux_bootstrap.id != "" ? true : false
}

output "flux_version" {
  description = "The version of Flux that was deployed"
  value       = var.flux_version
}

output "cilium_files" {
  description = "Paths to the generated Cilium configuration files"
  value       = var.cilium_enabled ? {
    repository = local_file.flux_cilium_repository[0].filename
    release    = local_file.flux_cilium_release[0].filename
  } : null
}
