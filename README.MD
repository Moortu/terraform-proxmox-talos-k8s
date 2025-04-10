# Terraform Proxmox Talos K8s

A comprehensive Infrastructure as Code (IaC) solution for deploying a production-ready Kubernetes cluster using [Talos Linux](https://www.talos.dev/) on Proxmox VMs with GitOps integration. This project allows you to easily spin up a fully functional Kubernetes cluster with Cilium CNI and optional GitOps tools (FluxCD and/or ArgoCD).

> *Inspired by [rgl/terraform-proxmox-talos](https://github.com/rgl/terraform-proxmox-talos) and [roeldev/iac-talos-cluster](https://github.com/roeldev/iac-talos-cluster).*

## Features

- **Automated Kubernetes Deployment**: Deploy a complete Kubernetes cluster with a single command
- **Talos Linux**: Secure, immutable Linux distribution built for Kubernetes
- **Proxmox Integration**: Seamless creation and management of Proxmox VMs
- **Cilium CNI**: Modern, eBPF-based networking with multiple deployment options (inline or GitOps managed)
- **GitOps Ready**: Built-in support for FluxCD and ArgoCD with smooth transition paths
- **Multi-Git Provider Support**: Compatible with GitHub, GitLab, and Gitea (cloud or self-hosted)
- **Flexible Networking**: Support for static IPs, DHCP, custom MAC addresses, and sorted IP assignments
- **DNS Configuration**: Automatic generation of DNS records for all nodes during plan phase
- **Customizable VM Placement**: Deploy control planes and workers across different Proxmox nodes 
- **Cilium Management Options**: Deploy Cilium via Talos manifests or through GitOps tools

## Prerequisites

### Required
- [OpenTofu](https://opentofu.org/) v1.7.0+ or [Terraform](https://www.terraform.io/) v1.7.0+
- Proxmox VE server v7.0+
- Proxmox API token with appropriate permissions (see [API token setup](#proxmox-api-token-setup))
- Storage location accessible to Proxmox for the Talos ISO (either central storage or per-node)
- DNS server where you can configure the records output by this module

### For GitOps Features (Optional)
- Git repository for storing cluster manifests (GitHub, GitLab, or Gitea)
- Personal Access Token with appropriate permissions for the Git provider
- See [README-gitops.md](./README-gitops.md) for detailed requirements

## Network Configuration Options

### Static IP Configuration (Default)
- A dedicated subnet for your Kubernetes cluster (e.g., 10.0.10.0/24)
- A Virtual IP (VIP) for the Kubernetes API server 
- Gateway accessible from the cluster network
- DNS server that can host records for your cluster domain
  There are more options for DNS setup, but the project does not provide support, see [DNS Setup Options](#dns-setup-options).

#### DHCP Configuration (Alternative)
To use DHCP instead of static IPs, set in your `myvars.auto.tfvars`:

```hcl
talos_network_dhcp = true
```

See the [DHCP Configuration Notes](#dhcp-configuration-notes) section below for important details about using DHCP with this project.

## Proxmox API Token Setup

1. Log in to your Proxmox web UI
2. Create a dedicated user or use an existing one
3. Create a role with appropriate permissions:
   - Navigate to Datacenter → Permissions → Roles
   - Click "Create" and add a role named "Terraform" with these permissions:
     - Datastore.Allocate, Datastore.AllocateSpace, Datastore.AllocateTemplate, Datastore.Audit
     - Pool.Allocate
     - Sys.Audit, Sys.Console, Sys.Modify
     - SDN.Use
     - VM.Allocate, VM.Audit, VM.Clone, VM.Config.CDROM, VM.Config.Cloudinit, VM.Config.CPU
     - VM.Config.Disk, VM.Config.HWType, VM.Config.Memory, VM.Config.Network, VM.Config.Options
     - VM.Migrate, VM.Monitor, VM.PowerMgmt
     - User.Modify
4. Assign the role to your user:
   - Navigate to Datacenter → Permissions → User Permissions
   - Click "Add" and select your user, the "Terraform" role, and set the path to "/"
5. Create the API token:
   - Navigate to Datacenter → Permissions → API Tokens
   - Click "Add" and create a token with the following settings:
     - User: Your user with the Terraform role
     - Token ID: A memorable name (e.g., terraform)
     - Privilege Separation: Disable for full access
6. Note the token value as it will only be shown once
7. Add these credentials to your `myvars.auto.tfvars` file

For more details, see the [Proxmox provider documentation](https://registry.terraform.io/providers/bpg/proxmox/latest/docs#api-token-authentication).

## Complete Variables Guide

This section explains all variables available in the project, how to determine their values, and recommendations for each setting.

### Proxmox Connection Variables

| Variable | Description | How to Determine | Options |
|----------|-------------|------------------|--------|
| `proxmox_api_url` | URL to your Proxmox API | Use `https://<proxmox-ip>:8006/api2/json` | N/A |
| `proxmox_user` | Proxmox user with API access | Use format `username@pve` or `username@pam` | Create a dedicated user for Terraform |
| `proxmox_api_token_id` | API token ID | Created in Proxmox UI under Datacenter → Permissions → API Tokens | Use a descriptive name like `terraform` |
| `proxmox_api_token_secret` | API token value | Shown only once when creating the token | Store securely, treat as a password |

### Network Configuration

| Variable | Description | How to Determine | Options |
|----------|-------------|------------------|--------|
| `talos_network_cidr` | Network CIDR for your cluster | Use your existing subnet (e.g., `192.168.1.0/24`) | Required even with DHCP |
| `talos_network_gateway` | Default gateway for nodes | Your network router's IP | Must be within the CIDR subnet |
| `talos_network_dhcp` | Whether to use DHCP | Set `true` for DHCP, `false` for static IPs | Static IPs (false) offer more predictable addressing |
| `use_kube_proxy` | Whether to use kube-proxy | Set `false` to use Cilium's eBPF for better performance | Legacy mode (true) is more compatible with older apps |

#### Static vs DHCP Configuration

By default, the project uses static IP assignment (`talos_network_dhcp = false`). IPs are calculated based on offsets from the CIDR base address.

Example with `talos_network_cidr = "192.168.1.0/24"` and `control_plane_first_ip = 10`:
- Control Plane 1: 192.168.1.10
- Control Plane 2: 192.168.1.11

Worker nodes start from `worker_node_first_ip`, usually 100 (e.g., 192.168.1.100).

#### DHCP Configuration Notes

When using DHCP (`talos_network_dhcp = true`), be aware of these important points:

1. **Network CIDR still required**: Even with DHCP enabled, `talos_network_cidr` is needed for:
   - Network mask and subnet configuration in Talos
   - Providing context for the VIP address
   - Internal networking configurations for Kubernetes

2. **VIP Implementation**:
   - The VIP (`talos_k8s_cluster_vip`) is NOT assigned by DHCP
   - Talos implements the VIP using Layer 2 networking (ARP) rather than DHCP
   - The IP specified must be within the network range but not assigned to other devices
   - The VIP floats between control plane nodes through leader election

3. **MAC Address Configuration**:
   - For stable DHCP operation, configure MAC addresses in node definitions:
   ```hcl
   proxmox_nodes = {
     "pve-node-01" = {
       control_planes = [{
         name = "control-plane-01"
         mac_address = "AA:BB:CC:11:22:01"
         # other settings...
       }]
     }
   }
   ```
   - These MAC addresses can be used for DHCP reservations to ensure consistent IP assignments

4. **DHCP Mode Considerations**:
   - DNS configuration output shows "DHCP (see VM console)" instead of actual IPs
   - DHCP reservations are recommended for all nodes for a stable cluster
   - GitOps tools use the VIP specified in `talos_k8s_cluster_vip` for connection

### Cluster Configuration

| Variable | Description | How to Determine | Options |
|----------|-------------|------------------|--------|
| `talos_k8s_cluster_name` | Name of your cluster | Choose a meaningful name | Keep it simple, no spaces |
| `talos_k8s_cluster_vip` | Virtual IP for API server | Choose an unused IP in your network | Must be in your subnet but not assigned to other devices |
| `talos_k8s_cluster_domain` | Internal domain for the cluster | Usually `cluster-name.local` or similar | This is for internal DNS records |
| `talos_k8s_cluster_endpoint_port` | API server port | Default `6443` is recommended | Change only if you have port conflicts |
| `control_plane_first_ip` | Starting IP offset for control planes | For static IPs, allocate a block of IPs | Typically use a lower range like `10-50` |
| `worker_node_first_ip` | Starting IP offset for workers | For static IPs, allocate a block of IPs | Typically use a higher range like `100-150` |
| `talos_install_disk_device` | Device path for Talos OS | Usually `/dev/vda` for Proxmox VMs | Check VM settings if using different drives |
| `control_plane_name_prefix` | Prefix for control plane nodes | Default is `talos-control-plane` | Use descriptive names for your environment |
| `worker_node_name_prefix` | Prefix for worker nodes | Default is `talos-worker-node` | Use descriptive names for your environment |
| `control_plane_first_id` | VM ID for first control plane | Default is `8100` | Change if you have ID conflicts in Proxmox |
| `worker_node_first_id` | VM ID for first worker | Default is `8200` | Change if you have ID conflicts in Proxmox |

### ISO and Storage Configuration

| Variable | Description | How to Determine | Options |
|----------|-------------|------------------|--------|
| `talos_iso_destination_filename` | ISO filename | Default includes version automatically | No need to change unless you have special requirements |
| `talos_iso_destination_server` | Proxmox node for ISO storage | Choose a reliable node | Leave empty to use the first node in `proxmox_nodes` |
| `talos_iso_destination_storage_pool` | Storage pool for ISO | Must be accessible by all Proxmox nodes | Choose `local` for single-node or a shared storage for clusters |
| `central_iso_storage` | ISO storage strategy | `true` for shared storage, `false` for per-node | Shared storage (true) is more efficient |

### Proxmox VM Configuration

| Variable | Description | How to Determine | Options |
|----------|-------------|------------------|--------|
| `proxmox_nodes` | Map of Proxmox nodes and VMs | List all Proxmox nodes in your cluster | Structure as shown in the example |

#### Node Configuration (Control Planes and Workers)

| Setting | Description | How to Determine | Options |
|---------|-------------|------------------|--------|
| `name` | Name for each node | Choose unique names | Prefixed automatically with defined prefixes |
| `node_labels` | Kubernetes labels | Add labels to organize nodes | Optional, use for node selection |
| `taints_enabled` | Taint control planes | `true` to prevent workloads on control planes | Recommended true for production |
| `network_bridge` | Proxmox network bridge | Usually `vmbr0` | Match your Proxmox network configuration |
| `mac_address` | MAC address for VMs | Set for DHCP reservations | Format as `AA:BB:CC:DD:EE:FF` |
| `cpu_type` | CPU type for VM | `host` passes through host CPU | Use `host` for best performance |
| `cpu_sockets` | Number of CPU sockets | Usually `1` is sufficient | Multiple sockets can help with license constraints |
| `cpu_cores` | CPU cores per VM | 2+ for control planes, 4+ for workers | Scale based on workload requirements |
| `memory` | RAM in GiB | 4+ for control planes, 8+ for workers | Scale based on workload requirements |
| `boot_disk_size` | Boot disk size in GiB | 20+ GB recommended | 0 uses Proxmox defaults |
| `boot_disk_storage_pool` | Storage pool for VMs | Must exist on the target Proxmox node | Local pools like `local-lvm` or shared storage |
| `data_disks` | Additional storage volumes | Define for persistent volumes | Optional, for additional storage needs |

### GitOps Configuration

| Variable | Description | How to Determine | Options |
|----------|-------------|------------------|--------|
| `include_cilium_inline_manifests` | Deploy Cilium via Talos | `true` for initial setup, `false` for GitOps | Start with `true`, then transition to GitOps |
| `deploy_fluxcd` | Deploy FluxCD | `true` to use FluxCD for GitOps | Choose either FluxCD or ArgoCD (or both) |
| `deploy_argocd` | Deploy ArgoCD | `true` to use ArgoCD for GitOps | Choose either FluxCD or ArgoCD (or both) |

#### FluxCD Configuration

| Variable | Description | How to Determine | Options |
|----------|-------------|------------------|--------|
| `fluxcd_git_provider` | Git provider type | `github`, `gitlab`, or `gitea` | Choose based on where your repos are hosted |
| `fluxcd_git_token` | Git access token | Create token with repo access | Keep secure, this is sensitive |
| `fluxcd_git_owner` | Git username/org | Your username or organization name | Case sensitive |
| `fluxcd_git_repository` | Git repo name | Repository for GitOps configuration | Create this repo before deployment |
| `fluxcd_git_branch` | Git branch | Usually `main` or `master` | Use an existing branch |
| `fluxcd_git_path` | Path in repo | Use `clusters/your-cluster-name` | Creates this structure if it doesn't exist |
| `fluxcd_git_url` | Custom Git URL | Only for self-hosted Gitea/GitLab | Leave empty for GitHub |
| `fluxcd_cilium_enabled` | Manage Cilium with FluxCD | Usually `true` | Set to `false` if using another method |
| `fluxcd_version` | FluxCD version | Default is usually appropriate | Check for compatibility with your Kubernetes version |
| `fluxcd_namespace` | FluxCD namespace | Default is `flux-system` | Rarely needs to be changed |
| `fluxcd_wait_for_resources` | Wait for FluxCD readiness | `true` recommended | Set to `false` to speed up deployment |

#### ArgoCD Configuration

| Variable | Description | How to Determine | Options |
|----------|-------------|------------------|--------|
| `argocd_git_provider` | Git provider type | `github`, `gitlab`, or `gitea` | Choose based on where your repos are hosted |
| `argocd_git_token` | Git access token | Create token with repo access | Keep secure, this is sensitive |
| `argocd_git_owner` | Git username/org | Your username or organization name | Case sensitive |
| `argocd_git_repository` | Git repo name | Repository for GitOps configuration | Create this repo before deployment |
| `argocd_git_branch` | Git branch | Usually `main` or `master` | Use an existing branch |
| `argocd_git_url` | Custom Git URL | Only for self-hosted Gitea/GitLab | Leave empty for GitHub |
| `argocd_cilium_enabled` | Manage Cilium with ArgoCD | Usually `true` | Set to `false` if using another method |
| `argocd_version` | ArgoCD Helm chart version | Default is usually appropriate | Check for compatibility with your Kubernetes version |
| `argocd_namespace` | ArgoCD namespace | Default is `argocd` | Rarely needs to be changed |
| `argocd_admin_password` | ArgoCD admin password | Set for a fixed password or leave empty for auto-generated | Empty is more secure |
| `argocd_wait_for_resources` | Wait for ArgoCD readiness | `true` recommended | Set to `false` to speed up deployment |

## Storage Preparation

### Option 1: Central ISO Storage (Recommended)
```hcl
talos_iso_destination_server = "pve-node-01" # Choose one node to host the ISO
talos_iso_destination_storage_pool = "nfs-iso" # Storage accessible by all nodes
central_iso_storage = true
```

### Option 2: Per-Node ISO Storage
```hcl
central_iso_storage = false # Will copy ISO to each node's local storage
```

## Quick Start

### 1. Clone the Repository
```bash
git clone https://github.com/your-username/terraform-proxmox-talos-k8s.git
cd terraform-proxmox-talos-k8s
```

### 2. Configure the Deployment

Create a `myvars.auto.tfvars` file with your configuration values based on [example.tfvars](./example.tfvars).

```hcl
# Essential configuration (sample values)
proxmox_api_url          = "https://your-proxmox-host:8006/api2/json"
proxmox_user             = "terraform-user@pve"
proxmox_api_token_id     = "your-token-id"
proxmox_api_token_secret = "your-token-secret"

talos_network_cidr       = "192.168.1.0/24"
talos_network_gateway    = "192.168.1.1"
talos_k8s_cluster_vip    = "192.168.1.100"
talos_k8s_cluster_name   = "talos-cluster"
talos_k8s_cluster_domain = "talos-cluster.local"

# Proxmox VM definitions
proxmox_nodes = {
  "pve-node-01" = {
    control_planes = [{
      name = "control-plane-01"
      # VM specs...
    }]
  }
  # Additional nodes...
}
```

See the full [example.tfvars](./example.tfvars) file for complete configuration options including:
- Cilium CNI configuration
- GitOps integration (FluxCD/ArgoCD)
- VM specifications
- Network options

### 3. Deploy the Cluster

```bash
# Initialize Terraform/OpenTofu
tofu init -upgrade

# Preview changes and check the DNS configuration
tofu plan

# Deploy the cluster
tofu apply -auto-approve
```

### 4. Configure DNS

After running `tofu plan` or `tofu apply`, you'll receive a DNS configuration guide output that looks like:

```
# DNS CONFIGURATION FOR your-cluster-name

# API/CONTROL PLANE VIP RECORD:
your-domain.com                IN    A    10.0.10.1
api.your-domain.com            IN    A    10.0.10.1

# CONTROL PLANE NODE RECORDS:
control-plane-01.your-domain.com    IN    A    10.0.10.10
control-plane-02.your-domain.com    IN    A    10.0.10.11
control-plane-03.your-domain.com    IN    A    10.0.10.12

# WORKER NODE RECORDS:
worker-01.your-domain.com    IN    A    10.0.10.100
worker-02.your-domain.com    IN    A    10.0.10.101
```

#### DNS Setup Options

If you don't have a dedicated DNS server, consider these alternatives:

##### Option 1: /etc/hosts (Simple Testing)

Add the DNS entries from your Terraform plan output to your `/etc/hosts` file (or `C:\Windows\System32\drivers\etc\hosts` on Windows). For example:

```
# These are EXAMPLE values - use the actual IPs and domains from your plan output:
192.168.1.100  api.your-cluster.local your-cluster.local
192.168.1.10   control-plane-01.your-cluster.local
192.168.1.11   control-plane-02.your-cluster.local
192.168.1.12   control-plane-03.your-cluster.local
192.168.1.100  worker-01.your-cluster.local
192.168.1.101  worker-02.your-cluster.local
```

This approach only works for machines where you've edited the hosts file.

##### Additional Options

- **Option 2: Lightweight DNS Server** - Set up a lightweight DNS server like dnsmasq or Pi-hole for small environments

- **Option 3: Router DNS Configuration** - Many home/SOHO routers support adding custom DNS entries in their admin interface

- **Option 4: Cloud-based DNS** - For internet-accessible clusters, consider services like Cloudflare or AWS 

NOTE: the above options are untested by me and I give no support.

### 4. Access Your Cluster

The deployment will create a kubeconfig file in the project directory that you can use to access your cluster:

```bash
export KUBECONFIG="$(pwd)/kubeconfig"
kubectl get nodes
```



### GitOps Integration

The project is built with GitOps in mind and supports deploying either or both popular GitOps tools:

- **FluxCD**: Enable with `deploy_fluxcd = true`
  - Implemented through a dedicated `modules/fluxcd` module
  - Supports GitHub, GitLab, and Gitea (both cloud and self-hosted)
  - Uses CLI bootstrap approach with provider-specific commands
  - Configurable with variables like `fluxcd_git_provider`, `fluxcd_git_owner`, etc.
  - Custom Git URL support for self-hosted GitLab and Gitea instances via `fluxcd_git_url`

- **ArgoCD**: Enable with `deploy_argocd = true`
  - Implemented through a dedicated `modules/argocd` module
  - Supports GitHub, GitLab, and Gitea (both cloud and self-hosted)
  - Deploys using Helm charts with Git repository configuration
  - Configurable with variables like `argocd_git_provider`, `argocd_git_owner`, etc.
  - Custom Git URL support for self-hosted instances via `argocd_git_url`

Both tools can be configured to manage Cilium with the `fluxcd_cilium_enabled` and `argocd_cilium_enabled` variables. The implementation creates the appropriate Kubernetes custom resources (HelmReleases for FluxCD, Applications for ArgoCD) that are initially suspended if inline manifests are enabled.

See [README-gitops.md](./README-gitops.md) for detailed GitOps configuration.

## CNI and GitOps Features

### Cilium CNI Management

Cilium is deployed with eBPF capabilities and can be managed in three ways:

1. **Talos Inline Manifests** (default): Cilium deployed directly through Talos
   - Set `include_cilium_inline_manifests = true`
   - Recommended for initial cluster setup
   - Includes all eBPF capabilities configured automatically

2. **FluxCD-Managed**: 
   - Set `deploy_fluxcd = true` and `fluxcd_cilium_enabled = true` 
   - The Helm release is created suspended when inline manifests are enabled
   - Automatically activates when inline manifests are disabled

3. **ArgoCD-Managed**: 
   - Set `deploy_argocd = true` and `argocd_cilium_enabled = true`
   - The Application is created suspended when inline manifests are enabled
   - Automatically activates when inline manifests are disabled

#### Recommended Transition Path

For a production-ready setup with GitOps, follow this sequence:

1. Start with Talos inline manifests for initial deployment (`include_cilium_inline_manifests = true`)
2. Deploy your preferred GitOps tool with Cilium configuration enabled
3. When GitOps is properly configured, disable inline manifests (`include_cilium_inline_manifests = false`)

This approach ensures zero network downtime during transitions as the GitOps-managed Cilium automatically activates when inline manifests are disabled.

Cilium's eBPF capabilities provide enhanced networking performance, security policies, observability features, and load balancing - all configured automatically regardless of the deployment method you choose.

## ISO Storage Configuration

This project supports two methods for handling the Talos ISO in Proxmox:

1. **Centralized Storage** (Default): The Talos ISO is downloaded once to a specified Proxmox node and used by all VMs. This is ideal when:
   - You have a shared storage solution accessible to all Proxmox nodes
   - You want to minimize bandwidth usage by downloading the ISO only once

2. **Per-Node Storage**: The Talos ISO is downloaded to each individual Proxmox node. This is useful when:
   - Your Proxmox nodes don't share a common storage location
   - Each node needs its own local copy of the ISO

Configure this behavior using the `central_iso_storage` variable in your tfvars file:

```hcl
# Use centralized storage (default)
central_iso_storage = true
talos_iso_destination_server = "pve-node-01"  # Node to store the central ISO

# Or use per-node storage
central_iso_storage = false  # ISO downloaded to each Proxmox node
```

## Configuration Options

Key configuration variables include:

| Variable | Description | Default |
|----------|-------------|--------|
| `talos_k8s_cluster_name` | Name of the Kubernetes cluster | `talos-cluster` |
| `talos_k8s_cluster_vip` | Virtual IP for the control plane | *Required* |
| `talos_version` | Talos Linux version | `1.5.5` |
| `k8s_version` | Kubernetes version | `1.28.0` |
| `central_iso_storage` | Use centralized ISO storage | `true` |
| `talos_iso_destination_server` | Node to store centralized ISO | First node if empty |
| `control_plane_nodes` | Control plane node configurations | *Required* |
| `worker_nodes` | Worker node configurations | *Required* |
| `deploy_fluxcd` | Whether to deploy FluxCD | `false` |
| `deploy_argocd` | Whether to deploy ArgoCD | `false` |
| `include_cilium_inline_manifests` | Whether to include Cilium manifests in Talos | `true` |

See the `vars-*.tf` files for complete configuration options.

## Cluster Management

### Scale the Cluster

Modify the `control_plane_nodes` or `worker_nodes` variables in your `myvars.auto.tfvars` file and run `tofu apply`.

### Upgrade the Cluster

Update the `talos_version` and/or `k8s_version` variables and run `tofu apply`.

### Destroy the Cluster

```bash
tofu destroy -auto-approve
```

### Recreate the Cluster

```bash
tofu destroy -auto-approve
tofu apply -auto-approve
```

## Troubleshooting

- **VM Creation Issues**: Verify Proxmox API credentials and permissions
- **Networking Problems**: Ensure proper network configuration and DNS resolution
- **Talos Bootstrap Failures**: Check VM console logs for detailed error messages
- **Cilium Issues**: When switching between management methods, verify both aren't trying to manage Cilium simultaneously

## License

This project is available under the MIT License.

## Acknowledgements

- [Talos Linux](https://www.talos.dev/) for the immutable Kubernetes-focused OS
- [Proxmox](https://www.proxmox.com/) for the virtualization platform
- [Cilium](https://cilium.io/) for the powerful CNI
- [FluxCD](https://fluxcd.io/) and [ArgoCD](https://argoproj.github.io/argo-cd/) for GitOps solutions
- [rgl/terraform-proxmox-talos](https://github.com/rgl/terraform-proxmox-talos) and [roeldev/iac-talos-cluster](https://github.com/roeldev/iac-talos-cluster) for inspiration
## Additional Implementation Notes

### Resource Allocation and VM Placement
- You can specify which VMs run on which Proxmox nodes with detailed resource allocation using the `proxmox_nodes` variable
- Control planes and workers can be distributed across any number of Proxmox nodes
- Each VM can have custom specifications (CPU, memory, disk size) configured independently

### IP Address Retrieval
- The project uses the `qemu-guest-agent` to retrieve IP addresses from VMs
- This works seamlessly for single-interface setups
- Multiple network interfaces on VMs may cause issues with automatic IP detection (untested)

### Configuration Assistance
- Most variables in `.tfvars` files have tooltips in supported editors for easier configuration
- Complex maps like `proxmox_nodes` may not have detailed tooltips
- Refer to the [example.tfvars](./example.tfvars) file for proper structure

### Talos Lifecycle Management
- The module will correctly handle upgrades and maintenance of Talos nodes
- When adding new nodes, they will automatically join the cluster
- When removing nodes, run `terraform destroy` to properly clean up resources