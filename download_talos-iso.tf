locals {
  talos_iso_image_location = "${var.talos_iso_destination_storage_pool}:iso/${replace(var.talos_iso_destination_filename, "%version%", var.talos_version)}"
}

data "talos_image_factory_extensions_versions" "this" {
  # get the latest talos version
  talos_version = "v${var.talos_version}"
  filters = {
    names = [
      "qemu-guest-agent",
    ]
  }
}

# see https://registry.terraform.io/providers/siderolabs/talos/0.6.0/docs/resources/image_factory_schematic
resource "talos_image_factory_schematic" "this" {
  schematic = yamlencode(
    {
      customization = {
        systemExtensions = {
          officialExtensions = data.talos_image_factory_extensions_versions.this.extensions_info.*.name
        }
      }
    }
  )
}

# See https://registry.terraform.io/providers/siderolabs/talos/0.6.0/docs/data-sources/image_factory_urls
data "talos_image_factory_urls" "this" {
  talos_version = "v${var.talos_version}"
  schematic_id  = talos_image_factory_schematic.this.id
  platform      = "metal"
}

# see https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_download_file
resource "proxmox_virtual_environment_download_file" "talos-iso" {
  content_type      = "iso"
  datastore_id      = var.talos_iso_destination_storage_pool
  file_name         = replace(var.talos_iso_destination_filename, "%version%", var.talos_version)
  node_name         = var.talos_iso_destination_server != "" ? var.talos_iso_destination_server : keys(var.proxmox_nodes)[0]
  overwrite         = false
  url               = data.talos_image_factory_urls.this.urls.iso_secureboot
}
