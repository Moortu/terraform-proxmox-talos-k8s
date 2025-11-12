output "vms_network" {
  depends_on = [time_sleep.wait_for_vms]
  value = [for idx, vm in proxmox_virtual_environment_vm.vm : {
    type                   = var.vm_type
    node_name              = vm.node_name
    vm_name                = vm.name
    vm_id                  = vm.vm_id
    network_interface_name = element(vm.network_interface_names, index(vm.mac_addresses, vm.network_device[0].mac_address))
    mac_address            = vm.network_device[0].mac_address
    ip                     = element(vm.ipv4_addresses, index(vm.mac_addresses, vm.network_device[0].mac_address))[0]
    taints_enabled         = lookup(var.vm_configs[tonumber(idx)], "taints_enabled", true)
  }]
}

output "vms_info" {
  depends_on = [time_sleep.wait_for_vms]
  value      = proxmox_virtual_environment_vm.vm
}
