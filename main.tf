terraform {
  required_version = ">= 1.7.0"

  required_providers {
    # see https://registry.terraform.io/providers/hashicorp/random
    # see https://github.com/hashicorp/terraform-provider-random
    random = {
      source  = "hashicorp/random"
      version = ">= 3.6.3"
    }
    # see https://registry.terraform.io/providers/bpg/proxmox
    # see https://github.com/bpg/terraform-provider-proxmox
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.66.1"
    }
    # see https://registry.terraform.io/providers/siderolabs/talos
    # see https://github.com/siderolabs/terraform-provider-talos
    talos = {
      source  = "siderolabs/talos"
      version = ">= 0.6.0"
    }
    # see https://registry.terraform.io/providers/hashicorp/helm
    # see https://github.com/hashicorp/terraform-provider-helm
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.15.0"
    }
    # see https://registry.terraform.io/providers/hashicorp/time
    # see https://github.com/hashicorp/terraform-provider-time
    time = {
      source  = "hashicorp/time"
      version = ">= 0.12.1"
    }
    # see https://registry.terraform.io/providers/fluxcd/flux/latest/docs
    # see https://github.com/fluxcd/terraform-provider-flux
    flux = {
      source  = "fluxcd/flux"
      version = ">= 1.2"
    }
    # see https://registry.terraform.io/providers/integrations/github/latest
    # see https://github.com/integrations/terraform-provider-github
    github = {
      source  = "integrations/github"
      version = ">= 6.3.0"
    }
    # see https://registry.terraform.io/providers/ivoronin/macaddress
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
  talos_iso_image_location = "${var.talos_iso_destination_storage_pool}:iso/${replace(var.talos_iso_destination_filename, "%", var.talos_version)}"
  talos_k8s_cluster_endpoint = "https://${var.talos_k8s_cluster_domain}:${var.talos_k8s_cluster_endpoint_port}"
}

module "talos_iso" {
  source = "./modules/download_talos_iso"

  providers = {
    proxmox = proxmox
    talos = talos
  }

  talos_iso_destination_filename = var.talos_iso_destination_filename
  talos_iso_destination_server = var.talos_iso_destination_server
  talos_iso_destination_storage_pool = var.talos_iso_destination_storage_pool
  talos_version = var.talos_version
  proxmox_nodes = var.proxmox_nodes
}

module "control_plane_vms" {
  depends_on = [ module.talos_iso ]
  source = "./modules/create_vms_control_plane"

  providers = {
    macaddress = macaddress
    proxmox = proxmox
  }

  proxmox_nodes = var.proxmox_nodes
  control_plane_first_id = var.control_plane_first_id
  control_plane_first_ip = var.control_plane_first_ip

  network_dhcp = var.network_dhcp
  network_cidr = var.network_cidr
  network_gateway = var.network_gateway
  talos_version = var.talos_version
  talos_iso_image_location = local.talos_iso_image_location
  control_plane_name_prefix = var.control_plane_name_prefix
}

module "workers_vms" {
  depends_on = [ module.talos_iso ]
  source = "./modules/create_vms_workers"

  providers = {
    macaddress = macaddress
    proxmox = proxmox
  }

  proxmox_nodes = var.proxmox_nodes
  worker_node_first_id = var.worker_node_first_id
  worker_node_first_ip = var.worker_node_first_ip
  network_dhcp = var.network_dhcp
  network_cidr = var.network_cidr
  network_gateway = var.network_gateway
  talos_version = var.talos_version
  talos_iso_image_location = local.talos_iso_image_location
  worker_node_name_prefix = var.worker_node_name_prefix
}

module "create_talos_config" {
  depends_on = [ module.control_plane_vms, module.workers_vms, module.talos_iso ]
  source = "./modules/create_talos_config"

  providers = {
    talos = talos
  }

  talos_k8s_cluster_domain = var.talos_k8s_cluster_domain
  talos_k8s_cluster_endpoint_port = var.talos_k8s_cluster_endpoint_port
  talos_k8s_cluster_name = var.talos_k8s_cluster_name
  talos_k8s_cluster_vip = var.talos_k8s_cluster_vip
  talos_version = var.talos_version
  network_gateway = var.network_gateway
  k8s_version = var.k8s_version
  talos_install_disk_device = var.talos_install_disk_device
  talos_control_plane_vms_network = module.control_plane_vms.talos_control_plane_vms_network
  talos_install_image_url = module.talos_iso.talos_image_url
} 
