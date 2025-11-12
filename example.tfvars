#######################################################################
# TERRAFORM-PROXMOX-TALOS-K8S EXAMPLE CONFIGURATION
#######################################################################
# This file contains example settings for deploying a Talos Kubernetes cluster on Proxmox.
# 1. Create a copy named 'myvars.auto.tfvars' and update the values to match your environment
# 2. Values marked with [REQUIRED] must be changed before deployment
# 3. Other values have sensible defaults but should be reviewed

#######################################################################
# PROXMOX API CONFIGURATION [REQUIRED]
#######################################################################
# Create a Proxmox API token with PVEDatastoreUser and PVEVMAdmin roles
proxmox_api_url          = "https://your-proxmox-host:8006/api2/json"  # [REQUIRED] URL of your Proxmox API
proxmox_user             = "example-user@pve"                            # [REQUIRED] Proxmox user with API access
proxmox_api_token_id     = "your-token-id"                           # [REQUIRED] API token ID
proxmox_api_token_secret = "your-token-secret"                       # [REQUIRED] API token secret

#######################################################################
# NETWORK CONFIGURATION [REQUIRED]
#######################################################################
# The network CIDR contains both subnet and prefix information (e.g., 10.0.10.0/24)
talos_network_cidr       = "192.168.1.0/24"  # [REQUIRED] Network CIDR for Talos nodes
talos_network_gateway    = "192.168.1.1"     # [REQUIRED] Gateway IP (your router)
talos_network_dhcp       = false             # Set to true if using DHCP instead of static IPs

#######################################################################
# TALOS ISO CONFIGURATION
#######################################################################
# Configure how the Talos ISO is stored and accessed in Proxmox

# ISO Storage Strategy (choose one):
# - true: Download ISO once to a central location (ideal with shared storage)
# - false: Download ISO to each Proxmox node separately (for non-shared storage setups)
central_iso_storage               = true

# When central_iso_storage=true, specify which node will store the ISO
# If left empty, the first node in proxmox_nodes will be used
talos_iso_destination_server      = "pve-node-01"

# Storage pool where the ISO will be stored (must exist on all nodes if central_iso_storage=false)
talos_iso_destination_storage_pool = "local"

download_method    = "remote"
local_download_dir = ".downloads"

#######################################################################
# KUBERNETES CLUSTER CONFIGURATION
#######################################################################
# Core cluster settings
talos_k8s_cluster_name         = "talos-cluster"       # Cluster name
talos_k8s_cluster_domain       = "talos-cluster.local" # [REQUIRED] Domain for cluster (configure in DNS)
talos_k8s_cluster_vip          = "192.168.1.100"       # [REQUIRED] Virtual IP for API server (must be in your network CIDR)
talos_k8s_cluster_endpoint_port = 6443                 # Kubernetes API port (usually keep default)

# Node IP address assignment
control_plane_first_ip = 10   # First IP offset for control planes (from CIDR base)
                              # Example: With CIDR 192.168.1.0/24, first CP gets 192.168.1.10
worker_node_first_ip   = 100  # First IP offset for workers (from CIDR base)
                              # Example: With CIDR 192.168.1.0/24, first worker gets 192.168.1.100

# Node naming and disk configuration
talos_install_disk_device  = "/dev/vda"           # Disk device for Talos OS installation
control_plane_name_prefix = "talos-control-plane" # Prefix for control plane node names
worker_node_name_prefix   = "talos-worker-node"   # Prefix for worker node names

#######################################################################
# PROXMOX VM CONFIGURATION [REQUIRED]
#######################################################################
# Define which Proxmox nodes will host which Talos VMs
# Each Proxmox node can host any number of control planes and workers

proxmox_nodes = {
  # Replace with your actual Proxmox node IDs
  "pve-node-01" = {  # [REQUIRED] First Proxmox node name/ID
    control_planes = [{  # Control plane VMs on this node
      name = "control-plane-01"  # Each node name must be unique
      node_labels = {  # Kubernetes labels to apply to the node
        role = "control-plane"
      }
      # Network and hardware configuration
      network_bridge         = "vmbr0"    # [REQUIRED] Proxmox network bridge
      mac_address            = ""         # Optional: Set fixed MAC address
      cpu_cores              = 2          # CPU cores for this VM
      memory                 = 4          # Memory in GB for this VM
      boot_disk_size         = 20         # Boot disk size in GB
      boot_disk_storage_pool = "local-lvm" # [REQUIRED] Proxmox storage pool for VM disks
    }]
    workers = []  # No worker VMs on this node
  },
  
  "pve-node-02" = {  # [REQUIRED] Second Proxmox node name/ID
    control_planes = [{  # Add more control planes for HA (3+ recommended for production)
      name = "control-plane-02"
      node_labels = {
        role = "control-plane"
      }
      network_bridge         = "vmbr0"
      cpu_cores              = 2
      memory                 = 4
      boot_disk_size         = 20
      boot_disk_storage_pool = "local-lvm"
    }],
    workers = [{  # Worker nodes on this Proxmox node
      name = "worker-01"
      node_labels = {
        role = "worker"
      }
      network_bridge         = "vmbr0"
      cpu_cores              = 4          # Workers typically need more resources
      memory                 = 8          # Adjust based on your workload needs
      boot_disk_size         = 50         # Larger disk for container storage
      boot_disk_storage_pool = "local-lvm"
    }]
  },
  
  # You can add more Proxmox nodes as needed
  # "pve-node-03" = { ... }
}

#######################################################################
# CNI (CILIUM) AND GITOPS CONFIGURATION
#######################################################################
# Cilium is the Container Network Interface (CNI) used in this cluster

# Which tool should manage Cilium: 'inline', 'flux', 'argo', or 'both'
# - inline: Managed by Talos inline manifests (recommended for initial setup)
# - flux: Managed by FluxCD (requires deploy_gitops = 'flux' or 'both')
# - argo: Managed by ArgoCD (requires deploy_gitops = 'argo' or 'both')
# - both: Managed by both FluxCD and ArgoCD (requires deploy_gitops = 'both')
cilium_management = "inline"

# Choose which GitOps tool(s) to deploy: 'none', 'flux', 'argo', or 'both'
# - none: Don't deploy any GitOps tools
# - flux: Deploy only FluxCD
# - argo: Deploy only ArgoCD
# - both: Deploy both FluxCD and ArgoCD
deploy_gitops = "none"  # Set to 'flux', 'argo', or 'both' to enable GitOps tools

# Variables below are only needed when deploy_gitops is not 'none'

#######################################################################
# GITOPS CONFIGURATION
#######################################################################

#######################################################################
# COMMON GIT PROVIDER CONFIGURATION (Legacy variables - kept for backward compatibility)
#######################################################################
gitops_git_provider = "github"  # Options: "github", "gitlab", "gitea"
gitops_git_token    = ""       # Personal access token
gitops_git_owner    = "username" # Git username or organization
gitops_git_url      = ""       # e.g., "https://git.example.com" (leave empty for github.com)

# Common wait for resources setting
gitops_wait_for_resources = true

#######################################################################
# FLUXCD REPOSITORY CONFIGURATION (Optional, only if deploy_gitops = 'flux' or 'both')
#######################################################################
# New variable structure for FluxCD
git_base_url        = ""        # Base URL (leave empty for github.com)
git_token           = ""        # [REQUIRED] Personal access token
git_org_or_username = "username" # [REQUIRED] Git username or organization
git_repository      = "fluxcd_repo"  # [REQUIRED] Git repository name for FluxCD
git_username        = "username"     # [REQUIRED] Git username for auth
fluxcd_cluster_path = "clusters/talos-cluster"  # Path within the Git repository

# Legacy variables - kept for backward compatibility
fluxcd_repository_name = "fluxcd_repo"  # Git repository name for FluxCD
fluxcd_branch = "main"                  # Git branch for FluxCD
fluxcd_path = "clusters/talos-cluster"  # Path within the Git repository for FluxCD

# These variables are kept for backward compatibility
# FluxCD Cilium Management
fluxcd_cilium_enabled = true  # Whether FluxCD should manage Cilium
# Note: When both include_cilium_inline_manifests=true and cilium_management='flux',
# FluxCD's Cilium HelmRelease will be created but suspended until you set
# include_cilium_inline_manifests=false

#######################################################################
# ARGOCD REPOSITORY CONFIGURATION (Optional, only if deploy_gitops = 'argo' or 'both')
#######################################################################
# New variable structure for ArgoCD
argocd_base_url        = ""        # Base URL (leave empty for github.com)
argocd_token           = ""        # [REQUIRED] Personal access token
argocd_org_or_username = "username" # [REQUIRED] Git username or organization
argocd_repository      = "argocd_repo"  # [REQUIRED] Git repository name for ArgoCD
argocd_username        = "username"     # [REQUIRED] Git username for auth
argocd_cluster_path    = "clusters/talos-cluster"  # Path within the Git repository

# Legacy variables - kept for backward compatibility
argocd_repository_name = "argocd_repo"  # Git repository name for ArgoCD
argocd_branch = "main"                 # Git branch for ArgoCD

# These variables are kept for backward compatibility
# ArgoCD Cilium Management
argocd_cilium_enabled = true  # Whether ArgoCD should manage Cilium
# Note: When both include_cilium_inline_manifests=true and cilium_management='argo',
# ArgoCD's Cilium Application will be created but suspended until you set
# include_cilium_inline_manifests=false

# ArgoCD Admin Password
argocd_admin_password = ""  # Leave empty to auto-generate a password