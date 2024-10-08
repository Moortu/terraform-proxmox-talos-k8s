terraform {
    required_version = ">= 1.7.0"

    required_providers {
        # see https://registry.terraform.io/providers/siderolabs/talos
        # see https://github.com/siderolabs/terraform-provider-talos
        talos = {
            source  = "siderolabs/talos"
            version = ">= 0.6.0"
        }
    }
}