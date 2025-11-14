stack {
  name        = "vms"
  description = "Create Proxmox VMs for Talos control planes and workers"
  id          = "prod-vms"
  
  after = ["tag:iso"]
  tags = ["vms"]
}

input "talos_iso_image_location" {
  backend      = "default"
  from_stack_id = "prod-iso"
  value        = outputs.talos_iso_image_location.value
}

globals {
  environment = "production"
  stack_name  = "vms"
}

terramate {
  config {
    run {
      env {
        TF_CLI_ARGS_plan  = tm_join(" ", tm_compact([
          tm_ternary(tm_fileexists("../${global.environment}.auto.tfvars"), "-var-file=../${global.environment}.auto.tfvars", ""),
          tm_ternary(tm_fileexists("../${global.environment}.shared.auto.tfvars"), "-var-file=../${global.environment}.shared.auto.tfvars", ""),
          tm_ternary(tm_fileexists("../${global.environment}.${global.stack_name}.auto.tfvars"), "-var-file=../${global.environment}.${global.stack_name}.auto.tfvars", "")
        ]))
        TF_CLI_ARGS_apply = tm_join(" ", tm_compact([
          tm_ternary(tm_fileexists("../${global.environment}.auto.tfvars"), "-var-file=../${global.environment}.auto.tfvars", ""),
          tm_ternary(tm_fileexists("../${global.environment}.shared.auto.tfvars"), "-var-file=../${global.environment}.shared.auto.tfvars", ""),
          tm_ternary(tm_fileexists("../${global.environment}.${global.stack_name}.auto.tfvars"), "-var-file=../${global.environment}.${global.stack_name}.auto.tfvars", "")
        ]))
      }
    }
  }
}
