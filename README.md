# Terraform Proxmox Talos Kubernetes

Automated deployment of a production-ready Talos Linux Kubernetes cluster on Proxmox using Terraform/OpenTofu and Terramate.

With this project I had a few goals:
- Simplicity: You can checkout the project and run it and you'll have a working cluster in a matter of minutes
- Configurable: I use sane defaults so you can just run the script, but at the same time you can configure it to your needs to a pretty good degree
- Bare minimum: In this project I have not included any apps that will run on the cluster, it's just a bare cluster setup
- GitOps ready: I use Terramate for stack orchestration and support both FluxCD and ArgoCD for GitOps workflows so after the cluster is up and running you can use GitOps to start configuring and installing

## 🎯 Overview

This project provides a modular, GitOps-ready infrastructure-as-code solution for deploying Talos Kubernetes clusters on Proxmox Virtual Environment. It uses Terramate for stack orchestration and supports both FluxCD and ArgoCD for GitOps workflows.

### Key Features

- **🚀 Automated Deployment**: Complete cluster setup from image download to bootstrapped Kubernetes
- **🔄 Modular Architecture**: Reusable Terraform modules for flexible configurations
- **📦 Stack-Based Workflow**: Ordered deployment stages managed by Terramate
- **🌐 High Availability**: Multi-node control plane with virtual IP (VIP) support
- **🔌 CNI Ready**: Integrated Cilium networking with multiple management options
- **🔧 GitOps Support**: Optional FluxCD and/or ArgoCD deployment
- **🏗️ Production Ready**: Designed for real-world production environments

## 📋 Prerequisites

### Required Software

1. **Terraform/OpenTofu** (>= 1.7.0)
   ```bash
   # Install OpenTofu (recommended)
   curl --proto '=https' --tlsv1.2 -fsSL https://get.opentofu.org/install-opentofu.sh | bash
   
   # Or install Terraform
   # https://developer.hashicorp.com/terraform/install
   ```

2. **Terramate** (>= 0.4.0)
   ```bash
   # Install Terramate
   curl -L https://github.com/terramate-io/terramate/releases/latest/download/terramate_$(uname -s)_$(uname -m).tar.gz | tar -xz -C /usr/local/bin terramate
   ```

3. **Make** (optional but recommended)
   ```bash
   # Usually pre-installed on Linux/macOS
   # On Debian/Ubuntu: sudo apt install make
   ```

4. **kubectl** (Kubernetes CLI)
   ```bash
   # Linux
   curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
   sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
   
   # macOS
   brew install kubectl
   
   # Or see: https://kubernetes.io/docs/tasks/tools/
   ```

5. **talosctl** (Talos CLI)
   ```bash
   # Linux
   curl -sL https://talos.dev/install | sh
   
   # macOS
   brew install siderolabs/tap/talosctl
   
   # Or download from: https://github.com/siderolabs/talos/releases
   ```

### Proxmox Requirements

- **Proxmox VE** 7.0 or later
- **API Token** with the following roles:
  - `PVEDatastoreUser` (for ISO storage)
  - `PVEVMAdmin` (for VM management)
- **Network Bridge** configured (typically `vmbr0`)
- **Storage Pools** for:
  - ISO files (e.g., `local`)
  - VM disks (e.g., `local-lvm`)

### Network Requirements

- **Static IP Range**: Available IPs for control plane and worker nodes
- **Virtual IP (VIP)**: One IP for the Kubernetes API server load balancer
- **Gateway Access**: Nodes need internet access for pulling container images
- **Local DNS Server** ⚠️ **REQUIRED**: This setup currently requires a local DNS server that can resolve:
  - The cluster VIP domain (e.g., `k8s.example.com` → `192.168.1.100`)
  - Individual node hostnames (optional but recommended)
  - You can use Pi-hole, dnsmasq, BIND, or your router's DNS if it supports custom entries

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone <repository-url>
cd terraform-proxmox-talos-k8s
```

### 2. Create Proxmox API Token

#### Step-by-Step Token Creation:

1. **Log into Proxmox Web UI** at `https://your-proxmox-ip:8006`

2. **Create a dedicated user** (recommended for security):
   - Navigate to **Datacenter → Permissions → Users**
   - Click **Add**
   - Username: `terraform@pve` (or your preferred name)
   - Realm: `Proxmox VE authentication server`
   - Click **Add**

3. **Assign required roles to the user**:
   - Navigate to **Datacenter → Permissions**
   - Click **Add → User Permission**
   - Path: `/` (root)
   - User: `terraform@pve`
   - Role: `PVEVMAdmin`
   - Click **Add**
   - Repeat for role: `PVEDatastoreUser`

4. **Create API Token**:
   - Navigate to **Datacenter → Permissions → API Tokens**
   - Click **Add**
   - User: `terraform@pve`
   - Token ID: `terraform-token` (or your preferred name)
   - **Uncheck** "Privilege Separation" (token inherits user permissions)
   - Click **Add**

5. **Save the token secret** ⚠️ **Important**:
   - The secret is shown **only once**
   - Copy both the Token ID and Secret
   - Example Token ID format: `terraform@pve!terraform-token`
   - Example Secret format: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`

6. **Use in configuration**:
   ```hcl
   proxmox_user             = "terraform@pve"
   proxmox_api_token_id     = "terraform-token"  # Just the token name, not the full ID
   proxmox_api_token_secret = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
   ```

### 3. Configure Variables

Create your configuration file:

```bash
cp example.tfvars stacks/production/production.auto.tfvars
```

Edit `stacks/production/production.auto.tfvars` with your settings (see [Configuration Guide](#-configuration-guide) below).

### 4. Initialize Terraform

```bash
make init
```

This initializes all stacks and downloads required providers.

### 5. Deploy the Cluster

Deploy the core infrastructure (img, VMs, and Talos configuration):

```bash
make apply
```

This runs the first three deployment stages:
- **01-talos-iso**: Downloads and uploads Talos ISO to Proxmox
- **02-vms**: Creates control plane and worker VMs
- **03-talos-config**: Generates Talos machine configurations

### 6. Apply Configuration and Bootstrap

After VMs are created and booted, apply the Talos configuration:

```bash
make apply-bootstrap
```

This completes the cluster setup:
- **04-apply-config**: Applies Talos configurations to nodes
- **05-bootstrap**: Bootstraps the Kubernetes cluster
- **06-argofluxcd**: (Optional) Deploys GitOps tools

### 7. Access Your Cluster

The kubeconfig will be generated in the project root:

```bash
export KUBECONFIG=$(pwd)/kubeconfig.yaml
kubectl get nodes
```

## 📝 Configuration Guide

### Required Configuration

Edit `stacks/production/production.auto.tfvars` and update these **required** fields:

#### 1. Proxmox API Configuration

```hcl
proxmox_api_url          = "https://192.168.1.100:8006/api2/json"  # Your Proxmox API URL
proxmox_user             = "terraform@pve"                          # Proxmox user
proxmox_api_token_id     = "your-token-id"                          # API token ID
proxmox_api_token_secret = "your-token-secret"                      # API token secret
```

#### 2. Network Configuration

```hcl
talos_network_cidr    = "192.168.1.0/24"  # Your network CIDR
talos_network_gateway = "192.168.1.1"     # Your gateway IP
talos_network_dhcp    = false             # Use static IPs (recommended)
```

#### 3. Cluster Configuration

```hcl
talos_k8s_cluster_name     = "talos-cluster"       # Cluster name
talos_k8s_cluster_domain   = "cluster.local"       # Cluster domain
talos_k8s_cluster_vip      = "192.168.1.100"       # Virtual IP for API server (must be available)
talos_k8s_cluster_vip_domain = "k8s.example.com"   # Optional: DNS name for VIP
```

#### 4. Node IP Assignment

```hcl
control_plane_first_ip = 10   # First control plane gets 192.168.1.10
worker_node_first_ip   = 100  # First worker gets 192.168.1.100
```

#### 5. Proxmox Nodes and VMs

Define your Proxmox nodes and the VMs they will host:

```hcl
proxmox_nodes = {
  "pve-node-01" = {
    control_planes = [{
      name                   = "control-plane-01"
      network_bridge         = "vmbr0"
      mac_address            = "bc:24:11:26:58:a1"  # Optional: fixed MAC
      cpu_cores              = 4
      memory                 = 8                     # GB
      boot_disk_size         = 20                    # GB
      boot_disk_storage_pool = "local-lvm"
      taints_enabled         = "false"
      node_labels = {
        role = "control-plane"
      }
    }]
    workers = []
  },
  
  "pve-node-02" = {
    control_planes = [{
      name                   = "control-plane-02"
      network_bridge         = "vmbr0"
      mac_address            = "bc:24:11:26:58:a2"
      cpu_cores              = 4
      memory                 = 8
      boot_disk_size         = 20
      boot_disk_storage_pool = "local-lvm"
      taints_enabled         = "false"
      node_labels = {
        role = "control-plane"
      }
    }]
    workers = [{
      name                   = "worker-01"
      network_bridge         = "vmbr0"
      mac_address            = "bc:24:11:39:f5:b1"
      cpu_cores              = 8
      memory                 = 16
      boot_disk_size         = 100
      boot_disk_storage_pool = "local-lvm"
      node_labels = {
        role = "worker"
      }
    }]
  }
}
```

### Optional Configuration

#### DNS Servers

```hcl
talos_name_servers = [
  "your-dns-server",
  "1.1.1.1",
  "8.8.8.8",
]
```

#### ISO Storage

```hcl
talos_iso_destination_storage_pool = "local"  # Storage pool for Talos ISO
```

#### Talos Installation Disk

```hcl
talos_install_disk_device = "/dev/sda"  # Disk device for Talos OS
```

#### CNI Management

```hcl
cilium_management = "inline"  # Options: inline, flux, argo, both
```

- **inline**: Cilium managed by Talos inline manifests (recommended for initial setup)
- **flux**: Managed by FluxCD (requires FluxCD deployment)
- **argo**: Managed by ArgoCD (requires ArgoCD deployment)
- **both**: Managed by both FluxCD and ArgoCD

## 🏗️ Architecture

### Deployment Stages

The project uses Terramate to orchestrate deployment in ordered stages:

| Stage | Directory | Description | Tag |
|-------|-----------|-------------|-----|
| 1 | `01-talos-iso` | Downloads Talos ISO and uploads to Proxmox | `iso` |
| 2 | `02-vms` | Creates control plane and worker VMs | `vms` |
| 3 | `03-talos-config` | Generates Talos machine configurations | `talos-config` |
| 4 | `04-apply-config` | Applies configurations to Talos nodes | `apply-config` |
| 5 | `05-bootstrap` | Bootstraps the Kubernetes cluster | `bootstrap` |
| 6 | `06-argofluxcd` | Deploys GitOps tools (optional) | `gitops` |

### Module Structure

```
modules/
├── compute/
│   ├── vm_base/              # Base VM creation logic
│   ├── vm_group_cp/          # Control plane orchestration
│   └── vm_group_workers/     # Worker node orchestration
├── talos/
│   ├── download_talos_image/ # ISO download and upload
│   ├── secrets/              # Talos machine secrets
│   ├── machine_config/       # Machine configuration generation
│   ├── apply_config/         # Configuration application
│   └── bootstrap/            # Cluster bootstrap
├── generate_cilium_manifest/ # Cilium CNI manifest generation
└── gitops/
    ├── fluxcd/               # FluxCD deployment
    └── argocd/               # ArgoCD deployment
```

## 🔧 Usage

### Make Commands

The project includes a Makefile for common operations:

```bash
# Deploy core infrastructure (ISO + VMs + Config)
make apply

# Deploy everything including bootstrap and GitOps
make apply-all

# Deploy only bootstrap stage
make apply-bootstrap

# Deploy specific tags
make apply-with-tags TAGS='iso vms'

# Destroy core infrastructure (reverse order)
make destroy

# Destroy everything (reverse order)
make destroy-all

# Initialize all stacks
make init

# Upgrade providers
make upgrade

# Show help
make help
```

### Manual Terramate Commands

For more control, use Terramate directly:

```bash
# Run command across all stacks
cd stacks/production
terramate run --enable-sharing -- tofu apply

# Run with specific tags
terramate run --enable-sharing --tags iso --tags vms -- tofu plan

# Run in reverse order (for destroy)
terramate run --reverse --enable-sharing -- tofu destroy

# Run on specific stack
cd stacks/production/01-talos-iso
tofu apply
```

### Deployment Workflow

#### Initial Deployment

1. **Deploy core infrastructure**:
   ```bash
   make apply
   ```
   This deploys stages 1-3 (ISO, VMs, Talos config).

2. **Wait for VMs to boot** (2-3 minutes):
   ```bash
   # Check VM status in Proxmox UI or via CLI
   ```

3. **Bootstrap the cluster**:
   ```bash
   make apply-bootstrap
   ```
   This deploys stages 4-6 (apply config, bootstrap, GitOps).

4. **Verify cluster**:
   ```bash
   export KUBECONFIG=$(pwd)/kubeconfig.yaml
   kubectl get nodes
   kubectl get pods -A
   ```

#### Updating Configuration

To update node configurations:

```bash
# Edit production.auto.tfvars
vim stacks/production/production.auto.tfvars

# Apply changes to specific stage
cd stacks/production/03-talos-config
tofu apply

cd ../04-apply-config
tofu apply
```

#### Scaling the Cluster

To add nodes:

1. Add new node definitions to `proxmox_nodes` in `production.auto.tfvars`
2. Run `make apply` to create new VMs
3. Run `make apply-bootstrap` to configure new nodes

#### Destroying the Cluster

```bash
# Destroy everything (reverse order)
make destroy-all

# Or destroy in stages
make destroy-bootstrap  # Destroy GitOps and bootstrap
make destroy            # Destroy VMs, config, and ISO
```

## 🔍 Troubleshooting

### Common Issues

#### VMs Not Booting

- **Check ISO upload**: Verify Talos ISO exists in Proxmox storage
- **Check network**: Ensure network bridge is correctly configured
- **Check resources**: Verify Proxmox node has sufficient CPU/RAM

#### Cluster Bootstrap Fails

- **Check VIP**: Ensure virtual IP is available and not in use
- **Check connectivity**: Verify nodes can reach each other
- **Check API endpoint**: Ensure `talos_k8s_cluster_vip` is accessible

#### Terramate Errors

- **Run init**: Ensure all stacks are initialized: `make init`
- **Check order**: Stacks must be applied in order (use tags)
- **Enable sharing**: Always use `--enable-sharing` flag

### Debug Commands

```bash
# Check Talos node status
talosctl --talosconfig=./talosconfig.yaml --nodes <node-ip> version

# Check Kubernetes cluster
kubectl --kubeconfig=./kubeconfig.yaml get nodes -o wide

# View Talos logs
talosctl --talosconfig=./talosconfig.yaml --nodes <node-ip> logs

# Check Cilium status
kubectl --kubeconfig=./kubeconfig.yaml -n kube-system get pods -l app.kubernetes.io/name=cilium
```

## 📚 Additional Resources

### Versions

This project uses the following versions (defined in `config/globals.tm.hcl`):

- **Talos Linux**: 1.11.5
- **Kubernetes**: 1.34.2
- **Cilium**: 1.18.4
- **FluxCD**: 2.2.3
- **ArgoCD**: 5.53.12

### Documentation Links

- [Talos Linux Documentation](https://www.talos.dev/)
- [Proxmox VE Documentation](https://pve.proxmox.com/pve-docs/)
- [Terramate Documentation](https://terramate.io/docs)
- [Cilium Documentation](https://docs.cilium.io/)
- [FluxCD Documentation](https://fluxcd.io/docs/)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)

## 🤝 Contributing

Contributions are welcome! Please ensure:

1. Modules remain focused and reusable
2. Stack configurations use proper Terramate tags
3. Documentation is updated for new features
4. Changes are tested in a development environment

## 📄 License

[Add your license information here]

## 🙏 Acknowledgments

Built with:
- [Talos Linux](https://www.talos.dev/) - Immutable Kubernetes OS
- [Proxmox VE](https://www.proxmox.com/) - Virtualization platform
- [Terramate](https://terramate.io/) - Terraform orchestration
- [Cilium](https://cilium.io/) - eBPF-based networking and security
