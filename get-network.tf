data "proxmox_virtual_environment_vms" "control-plane_vms" {
  tags      = ["talos"]
  filter {
    name   = "name"
    regex  = true
    values = ["control-plane-.*"]
  }
}

data "proxmox_virtual_environment_vms" "worker_vms" {
  tags      = ["talos"]
  filter {
    name   = "name"
    regex  = true
    values = ["worker-.*"]
  }
}

output "cp-vms" {
    value = proxmox_virtual_environment_vms.control-plane_vms
}

output "workers-vms" {
    value = proxmox_virtual_environment_vms.worker_vms
}