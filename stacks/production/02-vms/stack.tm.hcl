stack {
  name        = "vms"
  description = "Create Proxmox VMs for Talos control planes and workers"
  id          = "prod-vms"
  
  after = ["tag:iso"]
  tags = ["vms"]
}

globals {
  environment = "production"
  stack_name  = "vms"
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
