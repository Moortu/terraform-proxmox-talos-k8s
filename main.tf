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
      version = ">= 0.75.0"
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
      source = "fluxcd/flux"
      version = "1.5.1"
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
  talos_network_ip_prefix = var.talos_network_ip_prefix_override != null ? var.talos_network_ip_prefix_override : tonumber(split("/", var.talos_network_cidr)[1])
  talos_network_base_ip = split("/", var.talos_network_cidr)[0]
  
  # DNS records for the cluster
  cluster_dns_records = {
    api = "api.${var.talos_k8s_cluster_domain}"
    vip = var.talos_k8s_cluster_vip
  }
  
  # Cilium is deployed using inline manifests based on the include_cilium_inline_manifests variable
  
  # Manifest URLs with version substitution
  metrics_server_manifest = replace(var.metrics_server_manifest_url, "%version%", var.metrics_server_version)
  
  # GitOps configuration
  deploy_flux = try(var.deploy_gitops, "none") == "flux" || try(var.deploy_gitops, "none") == "both" || var.deploy_fluxcd
  deploy_argo = try(var.deploy_gitops, "none") == "argo" || try(var.deploy_gitops, "none") == "both" || var.deploy_argocd
  
  # Use the variable from auto.tfvars to control Cilium inline manifests
  using_inline_cilium = var.include_cilium_inline_manifests
  
  # Kubeconfig path for GitOps tools
  kubeconfig_path = "${path.root}/generated/kubeconfig"
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
  talos_architecture                  = var.talos_architecture
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
  count  = local.using_inline_cilium ? 1 : 0
  source = "./modules/generate_cilium_manifest"
  
  cilium_version = var.cilium_version  
  use_kube_proxy = var.use_kube_proxy     
  k8s_version = var.k8s_version
}

# Local variables related to GitOps configuration are already defined at the top of the file

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
  talos_name_servers              = var.talos_name_servers
  k8s_version                     = var.k8s_version
  talos_install_disk_device       = var.talos_install_disk_device
  talos_control_plane_vms_network = module.control_plane_vms.talos_control_plane_vms_network
  talos_install_image_url         = module.talos_iso.talos_installer_image_url
  # Only include Cilium if inline manifests are enabled and the cilium module exists
  cilium_manifests                = length(module.cilium) > 0 ? module.cilium[0].cilium_manifests : ""
  cilium_patch                    = length(module.cilium) > 0 ? module.cilium[0].talos_patch : {}
  include_cilium_inline_manifests = length(module.cilium) > 0
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
}

# Add a timeout to allow cluster initialization
resource "time_sleep" "wait_for_boot" {
  depends_on = [module.boot_talos_nodes]
  create_duration = "30s"
}

# Use the existing kubeconfig file
provider "flux" {
  kubernetes = {
    config_path = "${path.root}/generated/kubeconfig"
  }
  git = {
    url = "${var.git_base_url}/${var.git_org_or_username}/${var.git_repository}.git"
    http = {
      username = var.git_username
      password = var.git_token
    }
  }
}

# FluxCD deployment (optional)
module "fluxcd" {
  count      = local.deploy_flux ? 1 : 0
  depends_on = [time_sleep.wait_for_boot]
  source     = "./modules/fluxcd"
  
  # Git configuration
  git_base_url = var.git_base_url
  git_token = var.git_token
  git_org_or_username = var.git_org_or_username
  git_repository = var.git_repository
  git_username = var.git_username
  talos_k8s_cluster_domain = var.talos_k8s_cluster_domain
  fluxcd_cluster_path = var.fluxcd_cluster_path
}

# ArgoCD deployment (optional)
module "argocd" {
  count      = local.deploy_argo ? 1 : 0
  depends_on = [module.boot_talos_nodes]
  source     = "./modules/argocd"
  
  providers = {
    kubernetes = kubernetes
    helm       = helm
  }
  
  # Kubernetes configuration
  kubernetes_config_path = local.kubeconfig_path
  
  # Git configuration for ArgoCD using the new variables
  git_provider   = "github" # Using GitHub as the provider
  git_token      = var.argocd_token
  git_owner      = var.argocd_org_or_username
  git_repository = var.argocd_repository
  git_branch     = "main" # Default branch
  git_url        = var.argocd_base_url
  # Note: Using this variable in the module's local_file resource:
  # git_path is defined in the module but we're using argocd_cluster_path here
  
  # Cilium configuration has been removed
  
  # ArgoCD-specific configurations
  argocd_version   = var.argocd_version
  argocd_namespace = var.argocd_namespace
  argocd_admin_password = var.argocd_admin_password
  
  wait_for_resources = try(var.gitops_wait_for_resources, null) != null ? var.gitops_wait_for_resources : var.argocd_wait_for_resources
}