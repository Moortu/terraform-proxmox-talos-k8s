output "talos_machine_secrets" {
  value = talos_machine_secrets.talos
}

output "talos_machine_configuration_control_planes" {
  value = data.talos_machine_configuration.cp
}

output "talos_machine_configuration_workers" {
  value = data.talos_machine_configuration.wn
}