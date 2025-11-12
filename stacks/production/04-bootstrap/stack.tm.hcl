stack {
  name        = "bootstrap"
  description = "Apply Talos configs, bootstrap cluster, and deploy GitOps"
  id          = "prod-bootstrap"
  
  after = ["tag:talos-config"]
  tags = ["bootstrap"]
}

globals {
  environment = "production"
  stack_name  = "bootstrap"
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
