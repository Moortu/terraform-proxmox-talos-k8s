output "talos_control_plane_vms_network" {
  value = module.control_plane_vms.talos_control_plane_vms_network
}

output "talos_control_plane_vms_info" {
  value = module.control_plane_vms.talos_control_plane_vms_info
}

output "talos_worker_network" {
  value = module.workers_vms.talos_worker_network
}

output "talos_worker_vms_info" {
  value = module.workers_vms.talos_worker_vms_info
}
