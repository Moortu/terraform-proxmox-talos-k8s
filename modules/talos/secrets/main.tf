terraform {
  required_providers {
    talos = {
      source = "siderolabs/talos"
    }
  }
}

locals {
  talos_version = try(var.versions.talos, var.talos_version)
}

resource "talos_machine_secrets" "this" {
  talos_version = "v${local.talos_version}"
}
