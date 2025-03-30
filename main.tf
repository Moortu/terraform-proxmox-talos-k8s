terraform {
  required_version = ">= 1.9.0"

  required_providers {
    # see https://search.opentofu.org/provider/opentofu/random/v3.6.2
    # see https://github.com/hashicorp/terraform-provider-random
    random = {
      source  = "opentofu/random"
      version = ">= 3.6.3"
    }
    # see https://search.opentofu.org/provider/bpg/proxmox/latest
    # see https://github.com/bpg/terraform-provider-proxmox
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.74.0"
    }
    # see https://search.opentofu.org/provider/siderolabs/talos/latest
    # see https://github.com/siderolabs/terraform-provider-talos
    talos = {
      source  = "siderolabs/talos"
      version = ">= 0.7.1"
    }
    # see https://search.opentofu.org/provider/terraform-providers/helm/latest
    # see https://github.com/hashicorp/terraform-provider-helm
    helm = {
      source  = "terraform-providers/helm"
      version = ">= 2.17.0"
    }
    # see https://search.opentofu.org/provider/opentofu/time/latest
    # see https://github.com/hashicorp/terraform-provider-time
    time = {
      source  = "opentofu/time"
      version = ">= 0.13.0"
    }
    # see https://search.opentofu.org/provider/fluxcd/flux/latest
    # see https://github.com/fluxcd/terraform-provider-flux
    flux = {
      source  = "fluxcd/flux"
      version = ">= 1.5.1"
    }
    # see https://search.opentofu.org/provider/integrations/github/latest
    # see https://github.com/integrations/terraform-provider-github
    github = {
      source  = "integrations/github"
      version = ">= 6.6.0"
    }
    # see https://search.opentofu.org/provider/ivoronin/macaddress/latest
    # see https://github.com/ivoronin/terraform-provider-macaddress
    macaddress = {
      source  = "ivoronin/macaddress"
      version = ">= 0.3.2"
    }
  }
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


locals {
  talos_iso_image_location = "${var.talos_iso_destination_storage_pool}:iso/${replace(var.talos_iso_destination_filename, "%talos_version%", var.talos_version)}"
  talos_k8s_cluster_endpoint = "https://${var.talos_k8s_cluster_domain}:${var.talos_k8s_cluster_endpoint_port}"
}

module "talos_iso" {
  source = "./modules/download_talos_iso"

  providers = {
    proxmox = proxmox
    talos = talos
  }

  talos_iso_destination_filename      = var.talos_iso_destination_filename
  talos_iso_destination_server        = var.talos_iso_destination_server
  talos_iso_destination_storage_pool  = var.talos_iso_destination_storage_pool
  talos_version                       = var.talos_version
  proxmox_nodes                       = var.proxmox_nodes
}

module "control_plane_vms" {
  depends_on = [ module.talos_iso ]
  source = "./modules/create_vms_control_plane"

  providers = {
    macaddress = macaddress
    proxmox = proxmox
  }

  proxmox_nodes             = var.proxmox_nodes
  control_plane_first_id    = var.control_plane_first_id
  control_plane_first_ip    = var.control_plane_first_ip
  talos_network_dhcp        = var.talos_network_dhcp
  talos_network_cidr        = var.talos_network_cidr
  talos_network_gateway     = var.talos_network_gateway
  talos_version             = var.talos_version
  talos_iso_image_location  = local.talos_iso_image_location
  control_plane_name_prefix = var.control_plane_name_prefix
}

module "workers_vms" {
  depends_on = [ module.talos_iso ]
  source = "./modules/create_vms_workers"

  providers = {
    macaddress = macaddress
    proxmox = proxmox
  }

  proxmox_nodes             = var.proxmox_nodes
  worker_node_first_id      = var.worker_node_first_id
  worker_node_first_ip      = var.worker_node_first_ip
  talos_network_dhcp        = var.talos_network_dhcp
  talos_network_cidr        = var.talos_network_cidr
  talos_network_gateway     = var.talos_network_gateway
  talos_version             = var.talos_version
  talos_iso_image_location  = local.talos_iso_image_location
  worker_node_name_prefix   = var.worker_node_name_prefix
}

module "create_talos_config" {
  depends_on = [ module.control_plane_vms, module.workers_vms, module.talos_iso ]
  source = "./modules/create_talos_config"

  providers = {
    talos = talos
  }

  talos_k8s_cluster_domain        = var.talos_k8s_cluster_domain
  talos_k8s_cluster_endpoint_port = var.talos_k8s_cluster_endpoint_port
  talos_k8s_cluster_name          = var.talos_k8s_cluster_name
  talos_k8s_cluster_vip           = var.talos_k8s_cluster_vip
  talos_version                   = var.talos_version
  talos_network_gateway           = var.talos_network_gateway
  k8s_version                     = var.k8s_version
  talos_install_disk_device       = var.talos_install_disk_device
  talos_control_plane_vms_network = module.control_plane_vms.talos_control_plane_vms_network
  talos_install_image_url         = module.talos_iso.talos_image_url
} 

module "boot_talos_nodes" {
  depends_on = [ module.create_talos_config ]
  source = "./modules/boot_talos_nodes"

  providers = {
    talos = talos
  }
  talos_k8s_cluster_name                      = var.talos_k8s_cluster_name
  talos_k8s_cluster_endpoint                  = local.talos_k8s_cluster_endpoint
  talos_k8s_cluster_domain                    = var.talos_k8s_cluster_domain
  talos_k8s_cluster_endpoint_port             = var.talos_k8s_cluster_endpoint_port
  talos_k8s_cluster_vip                       = var.talos_k8s_cluster_vip
  talos_network_gateway                       = var.talos_network_gateway
  talos_network_ip_prefix                     = var.talos_network_ip_prefix
  control_planes_network                      = module.control_plane_vms.talos_control_plane_vms_network
  workers_network                             = module.workers_vms.talos_worker_network
  talos_machine_configuration_control_planes  = module.create_talos_config.talos_machine_configuration_control_planes
  talos_machine_configuration_workers         = module.create_talos_config.talos_machine_configuration_workers
  talos_machine_secrets                       = module.create_talos_config.talos_machine_secrets
}