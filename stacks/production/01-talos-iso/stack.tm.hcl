stack {
  name        = "talos-iso"
  description = "Download Talos ISO to Proxmox"
  id          = "prod-iso"
  tags        = ["iso"]
  
  after = []
}

output "talos_iso_image_location_output" {
  backend = "default"
  value   = outputs.talos_iso_image_location.value
}

globals {
  environment = "production"
  stack_name  = "talos-iso"
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
