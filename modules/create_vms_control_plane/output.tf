output "talos_control_plane_vms_info" {
  depends_on = [ time_sleep.wait_for_vms ]
  description = "The created control plane vms"
  value = proxmox_virtual_environment_vm.create_talos_control_plane_vms
}

output "talos_control_plane_vms_network" {
  depends_on = [ time_sleep.wait_for_vms ]
  value = [for idx, cp in proxmox_virtual_environment_vm.create_talos_control_plane_vms : {
    type                   = "control"
    node_name              = cp.node_name
    vm_name                = cp.name
    vm_id                  = cp.vm_id
    network_interface_name = element(cp.network_interface_names, index(cp.mac_addresses, cp.network_device[0].mac_address))
    mac_address            = cp.network_device[0].mac_address
    ip                     = element(cp.ipv4_addresses, index(cp.mac_addresses, cp.network_device[0].mac_address))[0]
    taints_enabled         = lookup(local.vm_control_planes[idx], "taints_enabled", true)
  }]
}
