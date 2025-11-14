# Generate provider configuration for all stacks
# This file is loaded by all stacks via the root terramate.tm.hcl import
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
    
    provider "proxmox" {
      endpoint  = tm_try(global.proxmox_api_url, var.proxmox_api_url)
      api_token = "${tm_try(global.proxmox_user, var.proxmox_user)}!${tm_try(global.proxmox_api_token_id, var.proxmox_api_token_id)}=${tm_try(global.proxmox_api_token_secret, var.proxmox_api_token_secret)}"
      insecure  = true
      tmp_dir   = "/var/tmp"
      
      ssh {
        agent    = true
        username = tm_try(global.proxmox_user, var.proxmox_user)
      }
    }
  }
}
