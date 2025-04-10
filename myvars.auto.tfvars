proxmox_api_url          = "https://10.0.0.50:8006/api2/json"
proxmox_user             = "terraform@pve"
proxmox_api_token_id     = "prov"
proxmox_api_token_secret = "21ae803a-b445-46b9-9230-8c1223234c95"

# Cluster configuration
talos_k8s_cluster_vip    = "10.0.10.1"
talos_k8s_cluster_name   = "kalimdor"
talos_k8s_cluster_domain = "kalimdor.lan"
control_plane_first_ip = 10
worker_node_first_ip = 100

talos_install_disk_device = "/dev/vda"
control_plane_name_prefix = "talos-control-plane"
worker_node_name_prefix = "talos-worker-node"

# Network configuration
talos_network_cidr       = "10.0.10.0/24"  # Network prefix (24) is derived from this
talos_network_gateway    = "10.0.0.1"
talos_network_dhcp       = false

# Talos iso configuration
talos_iso_destination_server = "pve-node-01"
talos_iso_destination_storage_pool = "truenas"
central_iso_storage = true  # Using centralized ISO storage with shared storage


proxmox_nodes = {
  pve-router-01 = {
    control_planes = [{
      name = "control-plane-01"
      node_labels = {
        role = "control-plane"
      }
      taints_enabled = true
      network_bridge         = "vmbr0"
      mac_address            = "BC:24:11:26:58:A1"
      cpu_cores              = 1
      memory                 = 2
      boot_disk_size         = 10
      boot_disk_storage_pool = "local-lvm"
    }]
    workers = []
  }

  pve-node-01 = {
    control_planes = [{
      name = "control-plane-02"
      node_labels = {
        role = "control-plane"
      }
      taints_enabled = false
      network_bridge         = "vmbr0"
      mac_address            = "BC:24:11:26:58:A2"
      cpu_cores              = 4
      memory                 = 14
      boot_disk_size         = 100
      boot_disk_storage_pool = "local-lvm"
    }]
    workers = [{
      name = "worker-01"
      node_labels = {
        role = "worker"
      }
      network_bridge         = "vmbr0"
      mac_address            = "BC:24:11:39:F5:B1"
      cpu_cores              = 4
      memory                 = 14
      boot_disk_size         = 100
      boot_disk_storage_pool = "local-lvm"
    }]
  }

  pve-node-02 = {
    control_planes = [{
      name = "control-plane-03"
      node_labels = {
        role = "control-plane"
      }
      taints_enabled = false
      network_bridge         = "vmbr0"
      mac_address            = "BC:24:11:26:58:A3"
      cpu_cores              = 4
      memory                 = 14
      boot_disk_size         = 100
      boot_disk_storage_pool = "local-lvm"
    }]
    workers = [{
      name = "worker-02"
      node_labels = {
        role = "worker"
      }
      network_bridge         = "vmbr0"
      mac_address            = "BC:24:11:39:F5:B2"
      cpu_cores              = 4
      memory                 = 14
      boot_disk_size         = 100
      boot_disk_storage_pool = "local-lvm"
    }]
  }
}

# Control whether to include Cilium manifests in Talos or let GitOps tools manage them
include_cilium_inline_manifests = true  # Set to false when GitOps is ready to manage Cilium

# Choose which GitOps tool(s) to deploy
deploy_fluxcd = true  # Set to true to deploy FluxCD
deploy_argocd = false # Set to true to deploy ArgoCD, can be used alongside FluxCD if needed

# FluxCD Configuration
fluxcd_git_provider = "github"  # Options: "github", "gitlab", "gitea"
fluxcd_git_token = "your-git-token-here"
fluxcd_git_owner = "your-git-username"
fluxcd_git_repository = "your-gitops-repository" 
fluxcd_git_branch = "main"
fluxcd_git_path = "clusters/kalimdor"
# For GitLab/Gitea self-hosted instances
fluxcd_git_url = ""  # e.g., "https://git.example.com"

# FluxCD Cilium Management
fluxcd_cilium_enabled = true  # Whether to set up Cilium through FluxCD

# ArgoCD Configuration
argocd_git_provider = "github"  # Options: "github", "gitlab", "gitea"
argocd_git_token = "your-git-token-here"
argocd_git_owner = "your-git-username"
argocd_git_repository = "your-gitops-repository"
argocd_git_branch = "main"
# For GitLab/Gitea self-hosted instances
argocd_git_url = ""  # e.g., "https://git.example.com"

# ArgoCD Cilium Management
argocd_cilium_enabled = true  # Whether to set up Cilium through ArgoCD

# ArgoCD Admin Password (Optional)
argocd_admin_password = ""  # Leave empty to auto-generate a password
