locals {

  vm_workers = flatten([
    for node_name, node in var.proxmox_nodes : [
      for worker in node.workers : merge(worker, {
        node_name = node_name
      })
    ]
  ])

  workers_map = { for wn in local.vm_workers : wn.name => wn }

  vm_worker_count = length(local.vm_workers)
}

# see https://registry.terraform.io/providers/ivoronin/macaddress/latest/docs/resources/macaddress
resource "macaddress" "talos-worker" {
  # see https://developer.hashicorp.com/terraform/language/meta-arguments/count
  count = local.vm_worker_count
}

# see https://registry.terraform.io/providers/bpg/proxmox/0.62.0/docs/resources/virtual_environment_vm
resource "proxmox_virtual_environment_vm" "talos-worker-vm" {
  depends_on = [
    proxmox_virtual_environment_download_file.talos-iso,
    macaddress.talos-worker
  ]
  #index all workers, map the index to a worker
  for_each = { for idx, wk in local.vm_workers : idx => wk }

  name            = each.value.name
  vm_id           = each.key + var.worker_node_first_id
  node_name       = each.value.node_name
  tags            = sort(["talos", "worker", "terraform"])
  on_boot         = true
  stop_on_destroy = true
  bios            = "ovmf"
  machine         = "q35"
  scsi_hardware   = "virtio-scsi-single"

  agent {
    enabled = true
  }

  tpm_state {
    version = "v2.0"
  }

  initialization {
    ip_config {
      ipv4 {
        address = var.network_dhcp ? "dhcp" : "${cidrhost(var.network_cidr, each.key + var.worker_node_first_ip)}/${split("/", var.network_cidr)[1]}"
        gateway = var.network_gateway
      }
    }
  }

  vga {
    type = "virtio"
    memory = "256"
  }

  cdrom {
    enabled = true
    file_id = replace(local.talos_iso_image_location, "%version%", var.talos_version)
  }

  cpu {
    type    = each.value.cpu_type
    sockets = each.value.cpu_sockets
    cores   = each.value.cpu_cores
    units   = 100
  }

  memory {
    dedicated = each.value.memory*1024
    floating = each.value.memory*1024
  }

  network_device {
    enabled     = true
    model       = "virtio"
    bridge      = each.value.network_bridge
    mac_address = each.value.mac_address != null ? each.value.mac_address : macaddress.talos-worker[each.key].address
    firewall    = false
  }

  operating_system {
    type = "l26" # Linux kernel type
  }

  disk {
    interface    = "virtio0"
    size         = each.value.boot_disk_size
    datastore_id = each.value.boot_disk_storage_pool
    iothread     = true
    ssd          = true
    discard      = "on"
    file_format  = "raw"
    backup       = false
  }

  # dynamic "disk" {
  #   for_each = var.worker_nodes[each.value.index].data_disks

  #   content {
  #     interface    = "virtio${each.value.index+1}"
  #     size         = disk.value.size
  #     datastore_id = disk.value.storage_pool != "" ? disk.value.storage_pool : var.proxmox_servers[each.value.target_server].disk_storage_pool
  #     file_format  = "raw"
  #     cache        = "none"
  #     iothread     = true
  #     backup       = false
  #   }
  # }
}

# locals {
#   workers-network = [for wn in proxmox_virtual_environment_vm.talos-worker-vm : {
#     type                   = "worker"
#     node_name              = wn.node_name
#     vm_name                = wn.name
#     vm_id                  = wn.vm_id
#     network_interface_name = element(wn.network_interface_names, index(wn.mac_addresses, wn.network_device[0].mac_address))
#     mac_address            = wn.network_device[0].mac_address
#     ip                     = element(wn.ipv4_addresses, index(wn.mac_addresses, wn.network_device[0].mac_address))[0]
#   }]
# }

# output "workers-network" {
#   depends_on = [ 
#     proxmox_virtual_environment_vm.talos-worker-vm
#    ]
#   value = [for wn in proxmox_virtual_environment_vm.talos-worker-vm : {
#     type                   = "worker"
#     node_name              = wn.node_name
#     vm_name                = wn.name
#     vm_id                  = wn.vm_id
#     network_interface_name = element(wn.network_interface_names, index(wn.mac_addresses, wn.network_device[0].mac_address))
#     mac_address            = wn.network_device[0].mac_address
#     ip                     = element(wn.ipv4_addresses, index(wn.mac_addresses, wn.network_device[0].mac_address))[0]
#   }]
# }
