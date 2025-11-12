stack {
  name        = "talos-config"
  description = "Generate Talos machine secrets and configurations"
  id          = "prod-talos-config"
  
  after = ["tag:vms"]
  tags = ["talos-config"]
}

globals {
  environment = "production"
  stack_name  = "talos-config"
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
