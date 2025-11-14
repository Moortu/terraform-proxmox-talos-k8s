terramate {
  required_version = ">= 0.4.0"
  
  config {
    git {
      default_branch = "main"
      default_remote = "origin"
    }
    
    run {
      env {
        # Ensure Terraform uses the stack directory as working directory
        TF_DATA_DIR = "${terramate.root.path.fs.absolute}${terramate.stack.path.absolute}/.terraform"
      }
    }
    
    experiments = ["outputs-sharing"]
  }
}

# Import global configuration
import {
  source = "./config/globals.tm.hcl"
}

sharing_backend "default" {
  type     = terraform
  filename = "sharing_generated.tf"
  command  = ["tofu", "output", "-json"]
}

# Generate provider configuration for all stacks
generate_hcl "_generated_providers.tf" {
  content {
    terraform {
      required_version = global.terraform_version
      
      required_providers {
        random = {
          source  = "opentofu/random"
          version = global.provider_versions.random
        }
        proxmox = {
          source  = "bpg/proxmox"
          version = global.provider_versions.proxmox
        }
        talos = {
          source  = "siderolabs/talos"
          version = global.provider_versions.talos
        }
        helm = {
          source  = "opentofu/helm"
          version = global.provider_versions.helm
        }
        kubernetes = {
          source  = "opentofu/kubernetes"
          version = global.provider_versions.kubernetes
        }
        time = {
          source  = "opentofu/time"
          version = global.provider_versions.time
        }
        flux = {
          source  = "fluxcd/flux"
          version = global.provider_versions.flux
        }
        github = {
          source  = "integrations/github"
          version = global.provider_versions.github
        }
        macaddress = {
          source  = "ivoronin/macaddress"
          version = global.provider_versions.macaddress
        }
      }
    }
  }
}
