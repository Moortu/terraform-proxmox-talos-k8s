# Global variables shared across all stacks
globals {
  # Project metadata
  project_name = "terraform-proxmox-talos-k8s"
  
  # OpenTofu version constraints (compatible with Terraform >= 1.7.0)
  terraform_version = ">= 1.7.0"
  
  # Provider versions
  provider_versions = {
    random      = ">= 3.7.2"      # https://search.opentofu.org/provider/opentofu/random/latest
    proxmox     = ">= 0.86.0"     # https://search.opentofu.org/provider/bpg/proxmox/latest
    talos       = ">= 0.9.0"      # https://search.opentofu.org/provider/siderolabs/talos/latest
    helm        = ">= 3.1.0"      # https://search.opentofu.org/provider/opentofu/helm/latest
    kubernetes  = "2.38.0"        # https://search.opentofu.org/provider/opentofu/kubernetes/latest
    time        = ">= 0.13.1"     # https://search.opentofu.org/provider/opentofu/time/latest
    flux        = "1.7.4"         # https://search.opentofu.org/provider/fluxcd/flux/latest
    github      = ">= 6.7.5"      # https://search.opentofu.org/provider/integrations/github/latest
    macaddress  = ">= 0.3.2"      # https://search.opentofu.org/provider/ivoronin/macaddress/latest
  }
  
  # Default versions (can be overridden per stack/environment)
  # https://github.com/siderolabs/talos/releases
  talos_version     = "1.11.5"
  
  # https://docs.siderolabs.com/talos/v1.11/getting-started/support-matrix
  # https://kubernetes.io/releases/
  k8s_version       = "1.34.2"
  
  # https://helm.cilium.io/
  cilium_version    = "1.18.4"
  
  # GitOps versions
  # https://search.opentofu.org/provider/fluxcd/flux/latest
  flux_version      = "2.2.3"
  
  # https://artifacthub.io/packages/helm/argo/argo-cd
  argocd_version    = "5.53.12"
  
  # Path to shared modules
  modules_path = "${terramate.root.path.fs.absolute}/modules"
}
