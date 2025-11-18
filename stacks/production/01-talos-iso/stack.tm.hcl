stack {
  name        = "talos-setup"
  description = "Download Talos files and prepare Proxmox"
  id          = "talos-setup"
  tags        = ["talos"]
  
  after = []
}


output "talos_disk_image_file_ids" {
  backend = "default"
  value   = module.talos_image.talos_disk_image_file_ids
}

globals {
  environment = "production"
  stack_name  = "talos-setup"
}
