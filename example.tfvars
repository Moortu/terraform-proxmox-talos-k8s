# Proxmox configuration
proxmox_user = "your-user@pve"
proxmox_api_token_id = "your-token-id"
proxmox_api_token_secret = "your-token-secret"
proxmox_api_url = "https://your-proxmox-host:8006/api2/json"

# Network configuration
talos_network_ip_prefix = 8
talos_network_cidr = "192.168.1.0/24"
talos_network_gateway = "192.168.1.1"
talos_network_dhcp = true
router_ip = "192.168.1.1"  # Optional, defaults to gateway

# Talos iso configuration
talos_iso_destination_server = "pve-node-01"
talos_iso_destination_storage_pool = "local"

# Cluster configuration
talos_k8s_cluster_name = "talos-cluster"
talos_k8s_cluster_vip = "192.168.1.100"  # Choose an available IP in your network
talos_k8s_cluster_domain = "talos-cluster.local"
talos_k8s_cluster_endpoint_port = 6443

control_plane_first_ip = 161
worker_node_first_ip = 171
talos_install_disk_device = "/dev/vda"

control_plane_name_prefix = "talos-control-plane"
worker_node_name_prefix = "talos-worker-node"

# Proxmox nodes configuration
proxmox_nodes = {
  pve-node-01 = {
    control_planes = [{
      name = "control-plane-01"
      node_labels = {
        role = "control-plane"
      }
      network_bridge         = "vmbr0"
      cpu_cores              = 4
      memory                 = 14
      boot_disk_size         = 100
      boot_disk_storage_pool = "local-lvm"
    }]
    workers = []
  }
  pve-node-02 = {
    control_planes = [{
      name = "control-plane-02"
      node_labels = {
        role = "control-plane"
      }
      network_bridge         = "vmbr0"
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
      cpu_cores              = 4
      memory                 = 14
      boot_disk_size         = 100
      boot_disk_storage_pool = "local-lvm"
    },
    {
      name = "worker-02"
      node_labels = {
        role = "worker"
      }
      network_bridge         = "vmbr0"
      cpu_cores              = 4
      memory                 = 14
      boot_disk_size         = 100
      boot_disk_storage_pool = "local-lvm"
    }]
  }
  pve-node-03 = {
    control_planes = []
    workers = [{
      name = "worker-03"
      node_labels = {
        role = "worker"
      }
      network_bridge         = "vmbr0"
      cpu_cores              = 4
      memory                 = 14
      boot_disk_size         = 100
      boot_disk_storage_pool = "local-lvm"
    }]
  }
}