output "talos_machine_secrets" {
  description = "The machine secrets"
  value       = talos_machine_secrets.talos
}

output "talos_machine_configuration_control_planes" {
  description = "The machine configuration for the control plane nodes"
  value       = data.talos_machine_configuration.cp
}

output "talos_machine_configuration_workers" {
  description = "The machine configuration for the worker nodes"
  value       = data.talos_machine_configuration.wn
}

output "talos_client_configuration" {
  description = "The talos client configuration"
  value       = data.talos_client_configuration.this
}