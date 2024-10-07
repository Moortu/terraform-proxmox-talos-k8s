terraform {
    required_version = ">= 1.7.0"

    required_providers {
        # see https://registry.terraform.io/providers/siderolabs/talos
        # see https://github.com/siderolabs/terraform-provider-talos
        talos = {
            source  = "siderolabs/talos"
            version = ">= 0.6.0"
        }
        # see https://registry.terraform.io/providers/hashicorp/time
        # see https://github.com/hashicorp/terraform-provider-time
        time = {
            source  = "hashicorp/time"
            version = ">= 0.12.1"
        }
    }
}