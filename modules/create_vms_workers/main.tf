locals {
  vm_workers = flatten([
    for node_name, node in var.proxmox_nodes : [
      for worker in node.workers : merge(worker, { node_name = node_name })
    ]
  ])

  vm_worker_count = length(local.vm_workers)
}

# see https://registry.terraform.io/providers/ivoronin/macaddress/latest/docs/resources/macaddress
resource "macaddress" "talos-worker" {
  # see https://developer.hashicorp.com/terraform/language/meta-arguments/count
  count = local.vm_worker_count
}

# see https://registry.terraform.io/providers/bpg/proxmox/0.62.0/docs/resources/virtual_environment_vm
resource "proxmox_virtual_environment_vm" "talos_worker_vms" {
  depends_on = [
    macaddress.talos-worker
  ]
  #index all workers, map the index to a worker
  for_each = { for idx, wk in local.vm_workers : idx => wk }

  name            = each.value.name != null ? each.value.name : "${var.worker_node_name_prefix}-${each.key}"
  vm_id           = each.key + var.worker_node_first_id
  node_name       = each.value.node_name
  tags            = ["talos", "worker", "terraform"]
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
        address = var.talos_network_dhcp ? "dhcp" : "${cidrhost(var.talos_network_cidr, each.key + var.worker_node_first_ip)}/${split("/", var.talos_network_cidr)[1]}"
        gateway = var.talos_network_dhcp ? null : var.talos_network_gateway
      }
    }
  }

  vga {
    type   = "virtio"
    memory = "256"
  }

  cdrom {
    enabled = true
    file_id = var.talos_iso_image_location
  }

  cpu {
    type    = each.value.cpu_type
    sockets = each.value.cpu_sockets
    cores   = each.value.cpu_cores
    units   = 100
  }

  memory {
    dedicated = each.value.memory*1024
    floating  = each.value.memory*1024
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
    discard      = "on"
    file_format  = "raw"
    backup       = false
  }

  efi_disk {
    datastore_id = each.value.boot_disk_storage_pool
    type = "4m"
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

resource "time_sleep" "wait_for_vms" {
  depends_on = [proxmox_virtual_environment_vm.talos_worker_vms]
  create_duration = "5s"
}