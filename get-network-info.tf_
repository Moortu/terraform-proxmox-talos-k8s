locals {
  control-planes_network = [for idx, cp in proxmox_virtual_environment_vm.talos-control-plane : {
    type                   = "control"
    node_name              = cp.node_name
    vm_name                = cp.name
    vm_id                  = cp.vm_id
    network_interface_name = element(cp.network_interface_names, index(cp.mac_addresses, cp.network_device[0].mac_address))
    mac_address            = cp.network_device[0].mac_address
    ip                     = element(cp.ipv4_addresses, index(cp.mac_addresses, cp.network_device[0].mac_address))[0]
  }]
  workers_network = [for wn in proxmox_virtual_environment_vm.talos-worker-node : {
    type                   = "worker"
    node_name              = wn.node_name
    vm_name                = wn.name
    vm_id                  = wn.vm_id
    network_interface_name = element(wn.network_interface_names, index(wn.mac_addresses, wn.network_device[0].mac_address))
    mac_address            = wn.network_device[0].mac_address
    ip                     = element(wn.ipv4_addresses, index(wn.mac_addresses, wn.network_device[0].mac_address))[0]
  }]
}
