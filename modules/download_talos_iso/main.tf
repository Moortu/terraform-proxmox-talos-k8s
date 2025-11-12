locals {
  # Prefer object inputs if provided, else fall back to legacy scalars
  dst_filename   = try(var.iso.filename_tpl, var.talos_iso_destination_filename)
  dst_server     = try(var.iso.server, var.talos_iso_destination_server)
  central        = try(var.iso.central_storage, var.central_iso_storage)
  storage_pool   = try(var.iso.storage_pool, var.talos_iso_destination_storage_pool)
  talos_version  = try(var.versions.talos, var.talos_version)
  arch           = try(var.iso.arch, var.talos_architecture)

  talos_iso_image_location = "${local.storage_pool}:iso/${replace(local.dst_filename, "%talos_version%", local.talos_version)}"

  # Local download helpers (used when download_method == "local_upload")
  local_iso_filename = replace(local.dst_filename, "%talos_version%", local.talos_version)
  local_iso_path     = "${var.local_download_dir}/${local.local_iso_filename}"
}

data "talos_image_factory_extensions_versions" "this" {
  # get the latest talos version
  talos_version = "v${local.talos_version}"
  filters = {
    names = [
      "qemu-guest-agen",
      "tailscale",
    ]
  }
}

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
  # Get the URL that will be used to download the ISO (non-secureboot to avoid 403)
  talos_iso_download_url = data.talos_image_factory_urls.generated_url.urls.iso_secureboot
  
  # Output the URL as a message using terraform console output
  # This will show during plan phase
  url_debug = formatlist("Talos ISO Download URL: %s", [local.talos_iso_download_url])
}

# Central ISO storage: Download to one location specified by talos_iso_destination_server
# see https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_download_file
resource "proxmox_virtual_environment_download_file" "talos_iso_central" {
  count            = var.download_method == "remote" && local.central ? 1 : 0
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
  for_each         = var.download_method == "remote" && !local.central ? var.proxmox_nodes : {}
  content_type     = "iso"
  datastore_id     = local.storage_pool
  file_name        = replace(local.dst_filename, "%talos_version%", local.talos_version)
  node_name        = each.key
  overwrite        = false
  # Using non-secureboot ISO to avoid factory.talos.dev 403s
  url              = data.talos_image_factory_urls.generated_url.urls.iso_secureboot
  verify           = false  # Skip URL verification to avoid permission issues
}

# ============================================================================
# Optional: download locally then upload to Proxmox (avoids remote URL probe)
# ============================================================================

resource "null_resource" "download_iso" {
  count = var.download_method == "local_upload" ? 1 : 0

  triggers = {
    url      = local.talos_iso_download_url
    filename = local.local_iso_filename
  }

  provisioner "local-exec" {
    command = "mkdir -p ${var.local_download_dir} && curl -fL --retry 5 --retry-delay 5 -o ${local.local_iso_path} ${local.talos_iso_download_url}"
  }
}

resource "proxmox_virtual_environment_file" "iso_upload_central" {
  count         = var.download_method == "local_upload" && local.central ? 1 : 0
  content_type  = "iso"
  datastore_id  = local.storage_pool
  node_name     = local.dst_server != "" ? local.dst_server : keys(var.proxmox_nodes)[0]

  source_file {
    path = local.local_iso_path
  }

  depends_on = [null_resource.download_iso]
}

resource "proxmox_virtual_environment_file" "iso_upload_per_node" {
  for_each      = var.download_method == "local_upload" && !local.central ? var.proxmox_nodes : {}
  content_type  = "iso"
  datastore_id  = local.storage_pool
  node_name     = each.key

  source_file {
    path = local.local_iso_path
  }

  depends_on = [null_resource.download_iso]
}
