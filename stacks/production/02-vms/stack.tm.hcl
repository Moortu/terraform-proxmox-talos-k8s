stack {
  name        = "vms"
  description = "Create Proxmox VMs for Talos control planes and workers"
  id          = "vms"
  
  after = ["tag:talos"]
  tags = ["vms"]
}


input "talos_disk_image_locations" {
  backend       = "default"
  from_stack_id = "talos-setup"
  value         = outputs.talos_disk_image_file_ids.value
}

globals {
  environment = "production"
  stack_name  = "vms"
}
