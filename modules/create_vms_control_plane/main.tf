locals {
  # First collect all control planes
  vm_control_planes_unsorted = flatten([
    for node_name, node in var.proxmox_nodes : [
      for control_plane in node.control_planes : merge(control_plane, { node_name = node_name })
    ]
  ])
  
  # Sort control planes by name for consistent IP assignment
  vm_control_planes_map = { for cp in local.vm_control_planes_unsorted : cp.name => cp }
  vm_control_planes = [ for name in sort(keys(local.vm_control_planes_map)) : local.vm_control_planes_map[name] ]

  vm_control_planes_count = length(local.vm_control_planes)
}

# see https://registry.terraform.io/providers/ivoronin/macaddress/latest/docs/resources/macaddress
resource "macaddress" "talos-control-plane" {
  # see https://developer.hashicorp.com/terraform/language/meta-arguments/count
  count = local.vm_control_planes_count
}

# see https://registry.terraform.io/providers/bpg/proxmox/0.62.0/docs/resources/virtual_environment_vm
resource "proxmox_virtual_environment_vm" "create_talos_control_plane_vms" {
  depends_on = [
    macaddress.talos-control-plane
  ]
  #index all cps, map the index to a cp
  for_each = { for idx, cp in local.vm_control_planes : idx => cp }

  name            = each.value.name != null ? each.value.name : "${var.control_plane_name_prefix}-${each.key}"
  vm_id           = each.key + var.control_plane_first_id
  node_name       = each.value.node_name
  tags            = ["talos", "controller", "terraform"]
  on_boot         = true
  stop_on_destroy = true
  bios            = "ovmf"
  machine         = "q35"
  scsi_hardware   = "virtio-scsi-single"

  agent {
    enabled = true
    timeout = "20m"
  }

  tpm_state {
    version = "v2.0"
  }

  initialization {
    ip_config {
      ipv4 {
        address = var.talos_network_dhcp ? "dhcp" : "${cidrhost(var.talos_network_cidr, parseint(each.key, 10) + var.control_plane_first_ip)}/${split("/", var.talos_network_cidr)[1]}"
        gateway = var.talos_network_dhcp ? null : var.talos_network_gateway
      }
    }
  }

  vga {
    type   = "virtio"
    memory = "256"
  }

  cdrom {
    file_id = var.talos_iso_image_location
  }

  cpu {
    type    = each.value.cpu_type
    sockets = each.value.cpu_sockets
    cores   = each.value.cpu_cores
    units   = 100
  }

  memory {
    dedicated = each.value.memory * 1024
    floating  = each.value.memory * 1024
  }

  network_device {
    enabled     = true
    model       = "virtio"
    bridge      = each.value.network_bridge
    mac_address = each.value.mac_address != null ? each.value.mac_address : macaddress.talos-control-plane[each.key].address
    firewall    = false
  }

  operating_system {
    type = "l26" # Linux kernel type
  }

  disk {
    interface    = "virtio0"
    size         = each.value.boot_disk_size
    datastore_id = each.value.boot_disk_storage_pool
    discard      = "on"
    file_format  = "raw"
    backup       = false
  }

  efi_disk {
    datastore_id = each.value.boot_disk_storage_pool
    type = "4m"
  }

  # didn't check if this works, so commented out
  # dynamic "disk" {
  #   for_each =  each.value.control_plane.data_disks

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

resource "time_sleep" "wait_for_vms" {
  depends_on = [proxmox_virtual_environment_vm.create_talos_control_plane_vms]
  create_duration = "5s"
}
