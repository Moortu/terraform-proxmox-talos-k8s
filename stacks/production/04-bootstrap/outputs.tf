output "kubeconfig" {
  value     = module.talos_bootstrap.kubeconfig
  sensitive = true
}

output "talosconfig" {
  value     = module.talos_bootstrap.talosconfig
  sensitive = true
}

output "kubeconfig_path" {
  value = module.talos_bootstrap.kubeconfig_path
}

output "talosconfig_path" {
  value = module.talos_bootstrap.talosconfig_path
}
