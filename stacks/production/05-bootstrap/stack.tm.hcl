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
