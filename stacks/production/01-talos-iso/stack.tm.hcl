stack {
  name        = "talos-iso"
  description = "Download Talos ISO to Proxmox"
  id          = "prod-iso"
  tags        = ["iso"]
  
  after = []
}

globals {
  environment = "production"
  stack_name  = "talos-iso"
}

terramate {
  config {
    run {
      env {
        TF_CLI_ARGS_plan  = "-var-file=../${global.environment}.auto.tfvars"
        TF_CLI_ARGS_apply = "-var-file=../${global.environment}.auto.tfvars"
      }
    }
  }
}
