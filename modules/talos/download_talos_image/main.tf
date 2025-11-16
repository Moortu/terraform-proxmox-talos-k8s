locals {
  # Prefer object inputs if provided, else fall back to legacy scalars
  talos_version  = try(var.versions.talos, var.talos_version)
  arch           = try(var.iso.arch, var.talos_architecture)
  datastore_id   = try(var.iso.storage_pool, var.talos_iso_destination_storage_pool)
  image_file_name = "talos-${talos_image_factory_schematic.this.id}-${local.talos_version}-metal-${local.arch}.raw"
}

# Optional: discover Talos image URLs via Image Factory (like ISO module)
data "talos_image_factory_extensions_versions" "this" {
  # get the latest talos version
  talos_version = "v${local.talos_version}"
  filters = {
    names = [
      "qemu-guest-agent",
      "amd-ucode",
      "util-linux-tools"
    ]
  }
}

resource "talos_image_factory_schematic" "this" {
  schematic = yamlencode({
    customization = {
      systemExtensions = {
        officialExtensions = data.talos_image_factory_extensions_versions.this.extensions_info.*.name
      }
    }
  })
}

data "talos_image_factory_urls" "generated_url" {
  talos_version = "v${local.talos_version}"
  schematic_id  = talos_image_factory_schematic.this.id
  platform      = "metal"
  architecture  = local.arch
}

resource "proxmox_virtual_environment_download_file" "talos_image_per_node" {
  for_each         = var.proxmox_nodes
  node_name        = each.key
  overwrite        = false

  content_type     = "import"
  datastore_id     = local.datastore_id
  # Download the secureboot disk image as raw.zst and decompress to .raw
  url              = replace(data.talos_image_factory_urls.generated_url.urls.disk_image_secureboot, ".zst", "")
  file_name        = local.image_file_name
  verify           = false  # Skip URL verification to avoid permission issues
}