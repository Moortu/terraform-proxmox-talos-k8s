locals {
  talos_iso_image_location = "${var.talos_iso_destination_storage_pool}:iso/${replace(var.talos_iso_destination_filename, "%version%", var.talos_version)}"

  vm_control_planes = flatten([
    for node_name, node in var.proxmox_nodes : [
      for control_plane in node.control_planes : {
        node_name = node_name
        control_plane = control_plane
      }
    ]
  ])

  vm_control_planes_count = length(local.vm_control_planes)
}

# see https://registry.terraform.io/providers/bpg/proxmox/0.62.0/docs/resources/virtual_environment_file
# this keeps bitching about the file already exists... i know, just skip it then
# resource "proxmox_virtual_environment_file" "talos-iso" {
#   content_type = "iso"
#   datastore_id = var.talos_iso_destination_storage_pool
#   node_name    = var.talos_iso_destination_server != "" ? var.talos_iso_destination_server : keys(var.proxmox_nodes)[0]
#   overwrite = false

#   source_file {
#     path      = replace(var.talos_iso_download_url, "%version%", var.talos_version)
#     file_name = replace(var.talos_iso_destination_filename, "%version%", var.talos_version)
#   }
# }

# see https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_download_file
resource "proxmox_virtual_environment_download_file" "talos-iso" {
  content_type      = "iso"
  datastore_id      = var.talos_iso_destination_storage_pool
  file_name         = replace(var.talos_iso_destination_filename, "%version%", var.talos_version)
  node_name         = var.talos_iso_destination_server != "" ? var.talos_iso_destination_server : keys(var.proxmox_nodes)[0]
  overwrite         = false
  url               = var.talos_iso_download_url
}

# see https://registry.terraform.io/providers/ivoronin/macaddress/latest/docs/resources/macaddress
resource "macaddress" "talos-control-plane" {
  # see https://developer.hashicorp.com/terraform/language/meta-arguments/count
  count = length(local.vm_control_planes)
}

# see https://registry.terraform.io/providers/bpg/proxmox/0.62.0/docs/resources/virtual_environment_vm
resource "proxmox_virtual_environment_vm" "talos-control-plane" {
  depends_on = [
    proxmox_virtual_environment_download_file.talos-iso,
    macaddress.talos-control-plane
  ]
  
  for_each = { for idx, cp in local.vm_control_planes : idx => cp }

  name            = "${var.control_plane_name_prefix}-${each.key + 1}"
  vm_id           = each.key + var.control_plane_first_id
  node_name       = each.value.node_name
  tags            = sort(["talos", "controller", "terraform"])
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
        address = var.network_dhcp ? "dhcp" : "${cidrhost(var.network_cidr, each.key + var.control_plane_first_ip)}/${split("/", var.network_cidr)[1]}"
        gateway = var.network_gateway
      }
    }
  }

  vga {
    type = "virtio"
  }

  cdrom {
    enabled = true
    file_id =  replace(local.talos_iso_image_location, "%version%", var.talos_version)
  }

  cpu {
    type    = each.value.control_plane.cpu_type
    sockets = each.value.control_plane.cpu_sockets
    cores   = each.value.control_plane.cpu_cores
    units   = 100
  }

  memory {
    dedicated = each.value.control_plane.memory*1024
    floating = each.value.control_plane.memory*1024
  }

  network_device {
    enabled     = true
    model       = "virtio"
    bridge      = each.value.control_plane.network_bridge
    mac_address = each.value.control_plane.mac_address != null ? each.value.control_plane.mac_address : macaddress.talos-control-plane[each.key].address
    firewall    = false
  }

  operating_system {
    type = "l26" # Linux kernel type
  }

  disk {
    interface    = "virtio0"
    size         = each.value.control_plane.boot_disk_size
    datastore_id = each.value.control_plane.boot_disk_storage_pool
    iothread     = true
    ssd          = true
    discard      = "on"
    file_format  = "raw"
    backup       = false
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

output "talos_control_plane_mac_addrs" {
  value = macaddress.talos-control-plane
}