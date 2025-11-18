stack {
  name        = "apply-config"
  description = "Apply Talos machine configurations to control planes and workers"
  id          = "prod-apply-config"

  after = ["tag:talos-config"]
  tags  = ["apply-config"]
}

globals {
  environment = "production"
  stack_name  = "apply-config"
}
