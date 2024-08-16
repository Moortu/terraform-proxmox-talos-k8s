terraform {
  required_providers {
    # see https://registry.terraform.io/providers/hashicorp/random
    # see https://github.com/hashicorp/terraform-provider-random
    random = {
      source  = "hashicorp/random"
      version = "3.6.2"
    }
    # see https://registry.terraform.io/providers/bpg/proxmox
    # see https://github.com/bpg/terraform-provider-proxmox
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.62.0"
    }
    # see https://registry.terraform.io/providers/siderolabs/talos
    # see https://github.com/siderolabs/terraform-provider-talos
    talos = {
      source  = "siderolabs/talos"
      version = "0.6.0-alpha.1"
    }
    # see https://registry.terraform.io/providers/hashicorp/helm
    # see https://github.com/hashicorp/terraform-provider-helm
    helm = {
      source  = "hashicorp/helm"
      version = "2.15.0"
    }
    # see https://registry.terraform.io/providers/ivoronin/macaddress
    # see https://github.com/ivoronin/terraform-provider-macaddress
    macaddress = {
      source  = "ivoronin/macaddress"
      version = "0.3.2"
    }
    # see https://registry.terraform.io/providers/kbst/kustomization/latest/docs
    # see https://github.com/kbst/terraform-provider-kustomization
    kustomization = {
      source  = "kbst/kustomization"
      version = "0.9.0"
    }
  }
  required_version = ">= 0.14"
}

provider "proxmox" {
    endpoint = var.proxmox_api_url
    # TODO: use terraform variable or remove the line, and use PROXMOX_VE_API_TOKEN environment variable
    api_token = "${var.proxmox_user}!${var.proxmox_api_token_id}=${var.proxmox_api_token_secret}" 
    # because self-signed TLS certificate is in use
    insecure = true
    # uncomment (unless on Windows...)
    tmp_dir  = "/var/tmp"

    ssh {
        agent = true
        username = var.proxmox_user
    }
}