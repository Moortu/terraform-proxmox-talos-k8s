# Git URL is constructed here to be used by the flux_bootstrap_git resource
locals {
  git_url = "${var.git_base_url}/${var.git_org_or_username}/${var.git_repository}.git"
}

resource "flux_bootstrap_git" "this" {
  cluster_domain       = var.talos_k8s_cluster_domain
  path                 = var.fluxcd_cluster_path
  embedded_manifests   = true
  
  # The authentication is now defined in the provider block in the root module
  # The git configuration details are passed through the provider
  
  # These are some of the most common settings you might want
  network_policy       = true
  watch_all_namespaces = true
  log_level            = "debug"


  timeouts = {
    create = "300s"
    read = "300s"
    update = "300s"
    delete = "300s"
  }  
  # Important: Make sure the CRDs are ready before applying custom resources
  components_extra     = ["image-reflector-controller", "image-automation-controller"]
  
}