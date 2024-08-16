locals {
  # loop over all nodes, then within a node loop, loop over all workers of that node
  # map the nodename and worker to an object. creating a list(worker, node_name)
  # example structure:
  # [{
  #   "worker" = {
  #     "boot_disk_size" = 100
  #     "boot_disk_storage_pool" = "local-lvm"
  #     "count" = 1
  #     "cpu_cores" = 4
  #     "cpu_sockets" = 1
  #     "cpu_type" = "host"
  #     "data_disks" = tolist([])
  #     "mac_address" = "BC:24:11:26:58:D3"
  #     "memory" = 14
  #     "network_bridge" = "vmbr0"
  #     "node_labels" = tomap({
  #       "role" = "worker"
  #     })
  #   }
  #   "node_name" = "pve-node-01"
  # },
  # {
  #   "worker" = {
  #     "boot_disk_size" = 100
  #     "boot_disk_storage_pool" = "local-lvm"
  #     "count" = 1
  #     "cpu_cores" = 4
  #     "cpu_sockets" = 1
  #     "cpu_type" = "host"
  #     "data_disks" = tolist([])
  #     "mac_address" = "BC:24:11:9A:2F:42"
  #     "memory" = 14
  #     "network_bridge" = "vmbr0"
  #     "node_labels" = tomap({
  #       "role" = "worker"
  #     })
  #   }
  #   "node_name" = "pve-node-02"
  # }]
  vm_workers = flatten([
    for node_name, node in var.proxmox_nodes : [
      for worker in node.workers : {
        node_name = node_name
        worker = worker
      }
    ]
  ])

  vm_worker_count = length(local.vm_workers)
}



# see https://registry.terraform.io/providers/ivoronin/macaddress/latest/docs/resources/macaddress
resource "macaddress" "talos-worker-node" {
  # see https://developer.hashicorp.com/terraform/language/meta-arguments/count
  count = local.vm_control_planes_count
}

# see https://registry.terraform.io/providers/bpg/proxmox/0.62.0/docs/resources/virtual_environment_vm
resource "proxmox_virtual_environment_vm" "talos-worker-node" {
  depends_on = [
    # proxmox_virtual_environment_download_file.talos-iso,
    macaddress.talos-worker-node
  ]
  #index all workers, map the index to a worker
  for_each = { for idx, wk in local.vm_workers : idx => wk }

  name            = "${var.worker_node_name_prefix}-${each.key + 1}"
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
    type    = each.value.worker.cpu_type
    sockets = each.value.worker.cpu_sockets
    cores   = each.value.worker.cpu_cores
    units   = 100
  }

  memory {
    dedicated = each.value.worker.memory*1024
    floating = each.value.worker.memory*1024
  }

  network_device {
    enabled     = true
    model       = "virtio"
    bridge      = each.value.worker.network_bridge
    mac_address = each.value.worker.mac_address != null ? each.value.worker.mac_address : macaddress.talos-control-plane[each.key].address
    firewall    = false
  }

  operating_system {
    type = "l26" # Linux kernel type
  }

  disk {
    interface    = "virtio0"
    size         = each.value.worker.boot_disk_size
    datastore_id = each.value.worker.boot_disk_storage_pool
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

output "talos_worker_node_mac_addrs" {
  value = macaddress.talos-worker-node
}