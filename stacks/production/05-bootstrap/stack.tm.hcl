stack {
  name        = "bootstrap"
  description = "Apply Talos configs and bootstrap Kubernetes cluster"
  id          = "prod-bootstrap"
  
  after = ["tag:talos-config"]
  tags  = ["bootstrap"]
}

globals {
  environment = "production"
  stack_name  = "bootstrap"
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
        TF_CLI_ARGS_destroy = tm_join(" ", tm_compact([
          tm_ternary(tm_fileexists("../${global.environment}.auto.tfvars"), "-var-file=../${global.environment}.auto.tfvars", ""),
          tm_ternary(tm_fileexists("../${global.environment}.shared.auto.tfvars"), "-var-file=../${global.environment}.shared.auto.tfvars", ""),
          tm_ternary(tm_fileexists("../${global.environment}.${global.stack_name}.auto.tfvars"), "-var-file=../${global.environment}.${global.stack_name}.auto.tfvars", "")
        ]))
      }
    }
  }
}
