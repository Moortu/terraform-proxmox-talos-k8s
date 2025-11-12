output "machine_secrets" {
  value     = module.talos_secrets.machine_secrets
  sensitive = true
}

output "client_configuration" {
  value     = module.talos_secrets.client_configuration
  sensitive = true
}

output "talos_config_cp" {
  value = module.talos_config_cp.machine_configuration
}

output "talos_config_worker" {
  value = module.talos_config_worker.machine_configuration
}

output "cilium_manifests" {
  value = length(module.cilium) > 0 ? module.cilium[0].cilium_manifests : ""
}
