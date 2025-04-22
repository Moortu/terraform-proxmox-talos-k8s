output "cilium_manifests" {
  description = "The generated Cilium manifests"
  value       = "${data.helm_template.cilium.manifest}"
}

output "cilium_version" {
  description = "The version of Cilium being deployed"
  value       = var.cilium_version
}

output "cilium_values" {
  description = "The Cilium values used for configuration"
  value       = local.cilium_values
}