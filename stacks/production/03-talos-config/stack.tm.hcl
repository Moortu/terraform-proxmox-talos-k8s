stack {
  name        = "talos-config"
  description = "Generate Talos machine secrets and configurations"
  id          = "prod-talos-config"
  
  after = ["tag:talos", "tag:vms"]
  tags = ["talos-config"]
}

globals {
  environment = "production"
  stack_name  = "talos-config"
}
