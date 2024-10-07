output "talos_worker_vms" {
  depends_on = [ time_sleep.wait_for_vms ]
  description = "The created control plane vms"
  value = proxmox_virtual_environment_vm.talos_worker_vms
}

output "talos_worker_network" {
  depends_on = [ time_sleep.wait_for_vms ]
  value = [for wn in proxmox_virtual_environment_vm.talos_worker_vms : {
    type                   = "worker"
    node_name              = wn.node_name
    vm_name                = wn.name
    vm_id                  = wn.vm_id
    network_interface_name = element(wn.network_interface_names, index(wn.mac_addresses, wn.network_device[0].mac_address))
    mac_address            = wn.network_device[0].mac_address
    ip                     = element(wn.ipv4_addresses, index(wn.mac_addresses, wn.network_device[0].mac_address))[0]
  }]
}