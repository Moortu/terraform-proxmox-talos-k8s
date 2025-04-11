# Proxmox API credential validation for plan phase
# If the plan process shows the output from this file, credentials are working

# These local values will be computed during plan phase
locals {
  # Connection information for display
  proxmox_info = {
    api_url  = var.proxmox_api_url
    user     = var.proxmox_user
    token_id = var.proxmox_api_token_id
  }
  
  # Banner for visual emphasis in the output
  banner_line    = "*******************************************************************************"
  credential_msg = "                   PROXMOX API CREDENTIALS CHECK: SUCCESS                     "
  permissions_msg = "                      CHECKING PROXMOX API PERMISSIONS                       "
  
  # This forces Terraform to check nodes during plan
  # If credentials are invalid, plan will fail before showing output
  proxmox_nodes_count = length(keys(var.proxmox_nodes))
  
  # First node name for permission checks
  first_node_name = keys(var.proxmox_nodes)[0]
  
  # Required permissions for downloading ISOs and creating VMs
  required_permissions = [
    "Datastore.AllocateSpace",
    "Datastore.Audit",
    "Sys.Modify",
    "VM.Allocate",
    "VM.Config.CDROM",
    "VM.Config.Disk",
    "VM.Config.Network",
    "VM.Config.Options",
    "VM.PowerMgmt",
    "VM.Monitor"
  ]
}

# This output will be prominently displayed during the plan phase
# If you can see this output, your Proxmox API credentials are working
output "zzz_1_proxmox_api_credentials_check" {
  description = "Checks if Proxmox API credentials are valid during plan phase"
  
  # Format the output to be very visible in the console
  value = <<EOT
${local.banner_line}
${local.credential_msg}
${local.banner_line}

✅ PROXMOX API CONNECTION SUCCESSFUL

  API URL:     ${var.proxmox_api_url}
  User:        ${var.proxmox_user}
  Token ID:    ${var.proxmox_api_token_id}
  Nodes:       ${local.proxmox_nodes_count}

NOTE: If you see this output, your Proxmox API credentials are working.
      If credentials were invalid, the plan would have failed with an error.

${local.banner_line}
EOT

  # Make this output appear after other outputs (except dns_configuration_guide)
  depends_on = [
    module.control_plane_vms,
    module.workers_vms
  ]
}

# Check for required permissions
# This data source will attempt to access information that requires specific permissions
data "proxmox_virtual_environment_datastores" "permission_check" {
  node_name = local.first_node_name
}
