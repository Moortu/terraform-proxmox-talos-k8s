output "cilium_manifests" {
  description = "The generated Cilium manifests"
  value       = "${data.helm_template.cilium.manifest}"
}

output "talos_patch" {
  description = "The Talos configuration patch to disable built-in CNI and optionally kube-proxy"
  value       = local.talos_patch
}

output "cilium_version" {
  description = "The version of Cilium being deployed"
  value       = var.cilium_version
}

output "cilium_values" {
  description = "The Cilium values used for configuration"
  value       = local.cilium_values
}