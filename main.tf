terraform {
  required_version = ">= 1.7.0"

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
      source  = "hashicorp/helm"
      version = ">= 2.17.0"
    }
    # https://search.opentofu.org/provider/hashicorp/kubernetes/v2.32.0
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.36.0"
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
  # ISO image configuration
  talos_iso_filename = replace(var.talos_iso_destination_filename, "%talos_version%", var.talos_version)
  talos_iso_path = "${var.talos_iso_destination_storage_pool}:iso/${local.talos_iso_filename}"
  
  # ISO paths for VMs to use in cdrom block
  # When central storage is used, all VMs use the same path
  # When per-node storage is used, we still generate the same path for all nodes (ISO is stored in the same relative location on each node)
  talos_iso_image_location = local.talos_iso_path
  
  # Determine which node will host the central ISO (if central storage is used)
  talos_iso_central_node = var.central_iso_storage ? (var.talos_iso_destination_server != "" ? var.talos_iso_destination_server : keys(var.proxmox_nodes)[0]) : null
  
  # Map of node names to ISO locations for per-node ISO storage (all nodes use same relative path)
  talos_iso_node_paths = {
    for node in keys(var.proxmox_nodes) : node => local.talos_iso_path
  }
  
  # Cluster endpoint and network configuration
  talos_k8s_cluster_endpoint = "https://${var.talos_k8s_cluster_domain}:${var.talos_k8s_cluster_endpoint_port}"
  talos_network_ip_prefix = tonumber(split("/", var.talos_network_cidr)[1])
  talos_network_base_ip = split("/", var.talos_network_cidr)[0]
  
  # DNS records for the cluster
  cluster_dns_records = {
    api = "api.${var.talos_k8s_cluster_domain}"
    vip = var.talos_k8s_cluster_vip
  }
  
  # These GitOps flags are already defined at the top of the file
  # Keeping them commented here for reference
  # using_gitops_for_cilium = (var.deploy_fluxcd && var.fluxcd_cilium_enabled) || (var.deploy_argocd && var.argocd_cilium_enabled)
  # include_cilium_inline_manifests = var.include_cilium_inline_manifests
  
  # Manifest URLs with version substitution
  metrics_server_manifest = replace(var.metrics_server_manifest_url, "%version%", var.metrics_server_version)
  
  # GitOps configuration
  using_gitops_for_cilium = (var.deploy_fluxcd && var.fluxcd_cilium_enabled) || (var.deploy_argocd && var.argocd_cilium_enabled)
  include_cilium_inline_manifests = var.include_cilium_inline_manifests
  
  # Kubeconfig path for GitOps tools
  kubeconfig_path = "${path.root}/talos-kubeconfig"
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
  central_iso_storage                 = var.central_iso_storage
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
  # Modified to handle both central and per-node ISO storage scenarios
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
  # Modified to handle both central and per-node ISO storage scenarios
  talos_iso_image_location  = local.talos_iso_image_location
  worker_node_name_prefix   = var.worker_node_name_prefix
}

module "cilium" {
  source = "./modules/generate_cilium_manifest"
  
  cilium_version = var.cilium_version  
  use_kube_proxy = var.use_kube_proxy     
  k8s_version = var.k8s_version
}

# Local variables related to GitOps configuration are already defined at the top of the file

module "create_talos_config" {
  depends_on = [ module.control_plane_vms, module.workers_vms, module.talos_iso, module.cilium ]
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
  cilium_manifests                = module.cilium.cilium_manifests
  cilium_patch                    = module.cilium.talos_patch
  # Include Cilium manifests inline only if we're not using either FluxCD or ArgoCD for Cilium
  include_cilium_inline_manifests = var.include_cilium_inline_manifests && !local.using_gitops_for_cilium
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
  talos_network_ip_prefix                     = local.talos_network_ip_prefix
  control_planes_network                      = module.control_plane_vms.talos_control_plane_vms_network
  workers_network                             = module.workers_vms.talos_worker_network
  talos_machine_configuration_control_planes  = module.create_talos_config.talos_machine_configuration_control_planes
  talos_machine_configuration_workers         = module.create_talos_config.talos_machine_configuration_workers
  talos_machine_secrets                       = module.create_talos_config.talos_machine_secrets
  cilium_manifests                            = module.cilium.cilium_manifests
}

# FluxCD deployment (optional)
module "fluxcd" {
  count      = var.deploy_fluxcd ? 1 : 0
  depends_on = [module.boot_talos_nodes]
  source     = "./modules/fluxcd"
  
  providers = {
    kubernetes = kubernetes
  }
  
  # Kubernetes configuration
  kubernetes_config_path = local.kubeconfig_path
  
  # Git configuration for Flux
  git_provider   = var.fluxcd_git_provider
  git_token      = var.fluxcd_git_token
  git_owner      = var.fluxcd_git_owner
  git_repository = var.fluxcd_git_repository
  git_branch     = var.fluxcd_git_branch
  git_path       = var.fluxcd_git_path
  git_url        = var.fluxcd_git_url
  
  # Cilium configuration
  cilium_enabled = var.fluxcd_cilium_enabled
  cilium_version = module.cilium.cilium_version
  cilium_values  = module.cilium.cilium_values
  managed_by_talos = local.include_cilium_inline_manifests
  
  # Flux-specific configurations
  flux_version   = var.fluxcd_version
  flux_namespace = var.fluxcd_namespace
  
  wait_for_resources = var.fluxcd_wait_for_resources
}

# ArgoCD deployment (optional)
module "argocd" {
  count      = var.deploy_argocd ? 1 : 0
  depends_on = [module.boot_talos_nodes]
  source     = "./modules/argocd"
  
  providers = {
    kubernetes = kubernetes
    helm       = helm
  }
  
  # Kubernetes configuration
  kubernetes_config_path = local.kubeconfig_path
  
  # Git configuration for ArgoCD
  git_provider   = var.argocd_git_provider
  git_token      = var.argocd_git_token
  git_owner      = var.argocd_git_owner
  git_repository = var.argocd_git_repository
  git_branch     = var.argocd_git_branch
  git_url        = var.argocd_git_url
  
  # Cilium configuration
  cilium_enabled = var.argocd_cilium_enabled
  cilium_version = module.cilium.cilium_version
  cilium_values  = module.cilium.cilium_values
  managed_by_talos = local.include_cilium_inline_manifests
  
  # ArgoCD-specific configurations
  argocd_version   = var.argocd_version
  argocd_namespace = var.argocd_namespace
  argocd_admin_password = var.argocd_admin_password
  
  wait_for_resources = var.argocd_wait_for_resources
}