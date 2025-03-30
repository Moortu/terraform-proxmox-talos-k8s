terraform {
    required_version = ">= 1.7.0"

    required_providers {
        # see https://registry.terraform.io/providers/ivoronin/macaddress
        # see https://github.com/ivoronin/terraform-provider-macaddress
        macaddress = {
            source  = "ivoronin/macaddress"
            version = ">= 0.3.2"
        }
        # see https://registry.terraform.io/providers/bpg/proxmox
        # see https://github.com/bpg/terraform-provider-proxmox
        proxmox = {
            source  = "bpg/proxmox"
            version = ">= 0.74.0"
        }
    }
}