locals {
  # Prefer object inputs if provided, else fall back to legacy scalars
  dst_filename   = try(var.iso.filename_tpl, var.talos_iso_destination_filename)
  dst_server     = try(var.iso.server, var.talos_iso_destination_server)
  central        = try(var.iso.central_storage, var.central_iso_storage)
  storage_pool   = try(var.iso.storage_pool, var.talos_iso_destination_storage_pool)
  talos_version  = try(var.versions.talos, var.talos_version)
  arch           = try(var.iso.arch, var.talos_architecture)

  talos_iso_image_location = "${local.storage_pool}:iso/${replace(local.dst_filename, "%talos_version%", local.talos_version)}"
}

data "talos_image_factory_extensions_versions" "this" {
  # get the latest talos version
  talos_version = "v${local.talos_version}"
  filters = {
    names = [
      "qemu-guest-agent",
      # "amd-ucode"
      # "tailscale",
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

# See https://registry.terraform.io/providers/siderolabs/talos/latest/docs/data-sources/image_factory_urls
data "talos_image_factory_urls" "generated_url" {
  talos_version = "v${local.talos_version}"
  schematic_id  = talos_image_factory_schematic.this.id
  platform      = "metal"
  architecture  = local.arch
}

# Add locals to output the URL for debugging
locals {
  # Get the URL that will be used to download the ISO
  talos_iso_download_url = data.talos_image_factory_urls.generated_url.urls.iso_secureboot
  
  # Output the URL as a message using terraform console output
  # This will show during plan phase
  url_debug = formatlist("Talos ISO Download URL: %s", [local.talos_iso_download_url])
}

# Central ISO storage: Download to one location specified by talos_iso_destination_server
# see https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_download_file
resource "proxmox_virtual_environment_download_file" "talos_iso_central" {
  count            = local.central ? 1 : 0
  content_type     = "iso"
  datastore_id     = local.storage_pool
  file_name        = replace(local.dst_filename, "%talos_version%", local.talos_version)
  node_name        = local.dst_server != "" ? local.dst_server : keys(var.proxmox_nodes)[0]
  overwrite        = false
  # Using secure boot ISO with AMD64 architecture (automatically selected by the image factory)
  url              = data.talos_image_factory_urls.generated_url.urls.iso_secureboot
  verify           = false  # Skip URL verification to avoid permission issues
}

# Per-node ISO storage: Download to each Proxmox node
# see https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_download_file
resource "proxmox_virtual_environment_download_file" "talos_iso_per_node" {
  for_each         = local.central ? {} : var.proxmox_nodes
  content_type     = "iso"
  datastore_id     = local.storage_pool
  file_name        = replace(local.dst_filename, "%talos_version%", local.talos_version)
  node_name        = each.key
  overwrite        = false
  # Using secure boot ISO with AMD64 architecture (automatically selected by the image factory)
  url              = data.talos_image_factory_urls.generated_url.urls.iso_secureboot
  verify           = false  # Skip URL verification to avoid permission issues
}
