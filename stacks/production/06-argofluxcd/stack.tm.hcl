stack {
  name        = "gitops"
  description = "Deploy GitOps tools (ArgoCD/FluxCD) to Talos cluster"
  id          = "gitops"
  
  after = ["tag:bootstrap"]
  tags  = ["gitops"]
}

globals {
  environment = "production"
  stack_name  = "gitops"
}
