output "vms_network" {
  value = [for idx, vm in proxmox_virtual_environment_vm.vm : {
    type       = var.vm_type
    node_name  = vm.node_name
    vm_name    = vm.name
    vm_id      = vm.vm_id
    # Find interface by MAC (case-insensitive match)
    network_interface_name = (
      length(vm.mac_addresses) > 0 ?
      element(vm.network_interface_names, index([for mac in vm.mac_addresses : upper(mac)], upper(vm.network_device[0].mac_address))) :
      "eth0"
    )
    mac_address = vm.network_device[0].mac_address
    # Get IP by matching MAC address (case-insensitive)
    ip = (
      length(vm.mac_addresses) > 0 ?
      element(vm.ipv4_addresses, index([for mac in vm.mac_addresses : upper(mac)], upper(vm.network_device[0].mac_address)))[0] :
      null
    )
    taints_enabled = lookup(var.vm_configs[tonumber(idx)], "taints_enabled", true)
  }]
}

output "vms_info" {
  value      = proxmox_virtual_environment_vm.vm
}
