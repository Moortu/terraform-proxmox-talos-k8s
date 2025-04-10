output "cluster_info" {
  description = "General cluster information for DNS configuration"
  value = {
    cluster_name   = var.talos_k8s_cluster_name
    cluster_domain = var.talos_k8s_cluster_domain
    cluster_vip    = var.talos_k8s_cluster_vip
  }
}

output "control_plane_nodes" {
  description = "Control plane node information for DNS configuration"
  value = {
    for idx, vm in module.control_plane_vms.talos_control_plane_vms_network : vm.vm_name => {
      name      = vm.vm_name
      ip        = var.talos_network_dhcp ? "DHCP (see VM console)" : vm.ip
      fqdn      = "${vm.vm_name}.${var.talos_k8s_cluster_domain}"
      dns_entry = "${vm.vm_name}.${var.talos_k8s_cluster_domain}    IN    A    ${var.talos_network_dhcp ? "DHCP (see VM console)" : vm.ip}"
    }
  }
}

output "worker_nodes" {
  description = "Worker node information for DNS configuration"
  value = {
    for idx, vm in module.workers_vms.talos_worker_network : vm.vm_name => {
      name      = vm.vm_name
      ip        = var.talos_network_dhcp ? "DHCP (see VM console)" : vm.ip
      fqdn      = "${vm.vm_name}.${var.talos_k8s_cluster_domain}"
      dns_entry = "${vm.vm_name}.${var.talos_k8s_cluster_domain}    IN    A    ${var.talos_network_dhcp ? "DHCP (see VM console)" : vm.ip}"
    }
  }
}

locals {
  # First, build lists of control planes and workers
  all_control_planes_unsorted = flatten([
    for node_name, node_config in var.proxmox_nodes : [
      for cp in try(node_config.control_planes, []) : {
        name = cp.name
        pve_node = node_name
      }
    ]
  ])
  
  all_workers_unsorted = flatten([
    for node_name, node_config in var.proxmox_nodes : [
      for worker in try(node_config.workers, []) : {
        name = worker.name
        pve_node = node_name
      }
    ]
  ])
  
  # Sort control planes and workers by name to ensure consistent IP assignment
  # This works by creating a map with name as the key, then getting the values in sorted key order
  control_planes_map = { for cp in local.all_control_planes_unsorted : cp.name => cp }
  all_control_planes = [ for name in sort(keys(local.control_planes_map)) : local.control_planes_map[name] ]
  
  workers_map = { for worker in local.all_workers_unsorted : worker.name => worker }
  all_workers = [ for name in sort(keys(local.workers_map)) : local.workers_map[name] ]
  
  # Then assign IP addresses with globally sequential indices based on sorted lists
  control_plane_nodes = [
    for i, cp in local.all_control_planes : {
      name = cp.name
      ip = var.talos_network_dhcp ? "DHCP (see VM console)" : cidrhost(var.talos_network_cidr, i + var.control_plane_first_ip)
    }
  ]
  
  worker_nodes = [
    for i, worker in local.all_workers : {
      name = worker.name
      ip = var.talos_network_dhcp ? "DHCP (see VM console)" : cidrhost(var.talos_network_cidr, i + var.worker_node_first_ip)
    }
  ]
}

# Add local variables for DNS formatting
locals {
  # Banner lines for DNS configuration output
  dns_banner_line = "*******************************************************************************"
  dns_header = "                      DNS CONFIGURATION FOR ${var.talos_k8s_cluster_name}                        "
}

output "zzz_2_dns_configuration_guide" {
  description = "DNS configuration summary for your cluster"
  value = <<EOT
${local.dns_banner_line}
${local.dns_header}
${local.dns_banner_line}

# API/CONTROL PLANE VIP RECORDS

  ${var.talos_k8s_cluster_domain}                IN    A    ${var.talos_k8s_cluster_vip}
  api.${var.talos_k8s_cluster_domain}            IN    A    ${var.talos_k8s_cluster_vip}

# CONTROL PLANE NODE RECORDS${join("", [
  for i, cp in local.all_control_planes : 
    "\n  ${format("%-40s", "${cp.name}.${var.talos_k8s_cluster_domain}")}IN    A    ${var.talos_network_dhcp ? "DHCP (see VM console)" : cidrhost(var.talos_network_cidr, i + var.control_plane_first_ip)}"
])}

# WORKER NODE RECORDS${join("", [
  for i, worker in local.all_workers : 
    "\n  ${format("%-40s", "${worker.name}.${var.talos_k8s_cluster_domain}")}IN    A    ${var.talos_network_dhcp ? "DHCP (see VM console)" : cidrhost(var.talos_network_cidr, i + var.worker_node_first_ip)}"
])}

NOTE: Add these entries to your DNS server or /etc/hosts file as shown above.
      These addresses must be accessible from your machines that need to connect to the cluster.

${local.dns_banner_line}
EOT

  # Ensure this output appears last in the plan
  depends_on = [
    module.control_plane_vms,
    module.workers_vms
  ]
}
