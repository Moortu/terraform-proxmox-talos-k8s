# Generate provider configuration for all stacks
generate_hcl "_generated_providers.tm.tf" {
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

# Generate Proxmox provider variables
generate_hcl "_generated_proxmox_vars.tm.tf" {
  content {
    variable "proxmox_api_url" {
      description = "Proxmox API URL"
      type        = tm_hcl_expression("string")
    }
    
    variable "proxmox_user" {
      description = "Proxmox user"
      type        = tm_hcl_expression("string")
    }
    
    variable "proxmox_api_token_id" {
      description = "Proxmox API token ID"
      type        = tm_hcl_expression("string")
    }
    
    variable "proxmox_api_token_secret" {
      description = "Proxmox API token secret"
      type        = tm_hcl_expression("string")
      sensitive   = true
    }
  }
}

# Generate Proxmox provider configuration
generate_hcl "_generated_proxmox_provider.tm.tf" {
  content {
    provider "proxmox" {
      endpoint  = tm_hcl_expression("var.proxmox_api_url")
      api_token = tm_hcl_expression("\"$${var.proxmox_user}!$${var.proxmox_api_token_id}=$${var.proxmox_api_token_secret}\"")
      insecure  = true
      tmp_dir   = "/var/tmp"
      
      ssh {
        agent    = true
        username = tm_hcl_expression("var.proxmox_user")
      }
    }
  }
}
