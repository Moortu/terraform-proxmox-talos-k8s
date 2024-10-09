output "talos_client_configuration" {
  value     = data.talos_client_configuration.talosconfig.talos_config
  sensitive = true
}

output "talos_cluster_kubeconfig" {
  value     = talos_cluster_kubeconfig.kubeconfig
  sensitive = true
}