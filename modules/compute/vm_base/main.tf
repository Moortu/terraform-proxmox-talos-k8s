terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
    }
    macaddress = {
      source = "ivoronin/macaddress"
    }
    time = {
      source = "opentofu/time"
    }
  }
}

locals {
  # Prefer object inputs, fall back to legacy scalars
  dhcp    = try(var.network.dhcp, var.talos_network_dhcp)
  cidr    = try(var.network.cidr, var.talos_network_cidr)
  gateway = try(var.network.gateway, var.talos_network_gateway)
  iso_loc = try(var.iso.image_location, var.talos_iso_image_location)

  # VM type tag
  vm_type_tag = var.vm_type == "control_plane" ? "controller" : "worker"
}

# Generate MAC addresses for VMs that don't have one specified
resource "macaddress" "vm" {
  count = length([for vm in var.vm_configs : vm if vm.mac_address == null || vm.mac_address == ""])
}

# Create VMs
resource "proxmox_virtual_environment_vm" "vm" {
  for_each = { for idx, vm in var.vm_configs : idx => vm }

  name            = each.value.name != null ? each.value.name : "${var.vm_specs.name_prefix}-${each.key}"
  vm_id           = each.key + var.vm_specs.first_id
  node_name       = each.value.node_name
  tags            = ["talos", local.vm_type_tag, "terraform"]
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
        address = local.dhcp ? "dhcp" : "${cidrhost(local.cidr, parseint(each.key, 10) + var.vm_specs.first_ip)}/${split("/", local.cidr)[1]}"
        gateway = local.dhcp ? null : local.gateway
      }
    }
  }

  vga {
    type   = "virtio"
    memory = "256"
  }

  cdrom {
    file_id = local.iso_loc
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
    mac_address = each.value.mac_address != null && each.value.mac_address != "" ? each.value.mac_address : macaddress.vm[index([for vm in var.vm_configs : vm if vm.mac_address == null || vm.mac_address == ""], each.value)].address
    firewall    = false
  }

  operating_system {
    type = "l26"
  }

  boot_order = ["virtio0", "ide3"]

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
    type         = "4m"
  }
}

resource "time_sleep" "wait_for_vms" {
  depends_on      = [proxmox_virtual_environment_vm.vm]
  create_duration = "5s"
}
