# Terraform Proxmox Talos Kubernetes Cluster

A comprehensive Infrastructure as Code (IaC) solution for deploying a production-ready Kubernetes cluster using [Talos Linux](https://www.talos.dev/) on Proxmox VMs with GitOps integration. This project allows you to easily spin up a fully functional Kubernetes cluster with Cilium CNI and optional GitOps tools (FluxCD and/or ArgoCD).

> *Inspired by [rgl/terraform-proxmox-talos](https://github.com/rgl/terraform-proxmox-talos) and [roeldev/iac-talos-cluster](https://github.com/roeldev/iac-talos-cluster).*

## Features

- **Automated Kubernetes Deployment**: Deploy a complete Kubernetes cluster with a single command
- **Talos Linux**: Secure, immutable Linux distribution built for Kubernetes
- **Proxmox Integration**: Seamless creation and management of Proxmox VMs
- **Cilium CNI**: Modern, eBPF-based networking with flexible deployment options
- **GitOps Ready**: Built-in support for FluxCD and ArgoCD
- **Multi-Git Provider Support**: Compatible with GitHub, GitLab, and Gitea
- **Flexible Networking**: Support for static IPs, DHCP, custom MAC addresses, and more
- **Customizable**: Easily configurable cluster size, VM specs, and features

## Prerequisites

- [OpenTofu](https://opentofu.org/) v1.7.0+ or [Terraform](https://www.terraform.io/) v1.7.0+
- Proxmox VE server v7.0+
- Proxmox API token with appropriate permissions
- Storage location accessible to Proxmox for the Talos ISO (e.g., NFS storage)
- DNS resolution for your cluster domain

## Quick Start

### 1. Prepare Proxmox

1. Create a Proxmox user with API token access
2. Ensure you have storage configured to store the Talos ISO (e.g., NFS storage)
3. Make sure your network is properly configured for VM connectivity

### 2. Configure the Deployment

Create a `myvars.auto.tfvars` file with your configuration values (see [example.tfvars](./example.tfvars) for a template).

### 3. Deploy the Cluster

```bash
# Initialize Terraform/OpenTofu
tofu init -upgrade

# Preview changes (optional)
tofu plan

# Deploy the cluster
tofu apply -auto-approve
```

### 4. Access Your Cluster

The deployment will create a kubeconfig file in the project directory that you can use to access your cluster:

```bash
export KUBECONFIG="$(pwd)/kubeconfig"
kubectl get nodes
```

## Network Configuration

This project offers flexible networking options:

- **Default**: Random MAC addresses with DHCP
- **Static IPs**: Set `network_dhcp = false` to use IPs generated from `network_cidr`, `control_plane_first_ip`, and `worker_first_ip`
- **Custom Configuration**: Specify exact MAC addresses and IPs per node if needed

> **Note**: Ensure DNS resolution is available for `talos_k8s_cluster_domain` in your network

## GitOps Integration

The project supports deploying and managing applications through GitOps with FluxCD and/or ArgoCD:

- **FluxCD**: Enable with `deploy_fluxcd = true`
- **ArgoCD**: Enable with `deploy_argocd = true`
- **Cilium Management**: Control whether Cilium is managed via inline manifests or GitOps

See [README-gitops.md](./README-gitops.md) for detailed GitOps configuration options.

## Cilium CNI Management

Cilium can be deployed in three ways:

1. **Talos Inline Manifests** (default): Cilium deployed directly through Talos
2. **FluxCD-Managed**: Cilium managed through FluxCD Helm releases
3. **ArgoCD-Managed**: Cilium managed through ArgoCD Applications

Transitioning between methods is seamless with the `include_cilium_inline_manifests` option.

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
in create_talos-config, the qemu agent is used to retrieve all ipaddresses from control-planes, if you have more then 1 interface set up, it might break something, I haven't tested with more then 1 interface.

Through the config you can specify what vm's you want to run on what nodes and with what resources with high specificity.
For now the worker and control plane config is basically the same, but this might change in the future.

most variables in .tfvars are hoverable for description, but for the complex ones like proxmox_nodes you have to look it up yourself

## proxmox api token access setup:
Instructions:
https://registry.terraform.io/providers/bpg/proxmox/latest/docs#api-token-authentication

in a shell on proxmox
1. Create a user:
pveum user add terraformAccess@pve

2. Create a role for the user - The list of privileges above is only an example atm
 pveum role add Terraform -privs "Datastore.Allocate Datastore.AllocateSpace Datastore.AllocateTemplate Datastore.Audit Pool.Allocate Sys.Audit Sys.Console Sys.Modify SDN.Use VM.Allocate VM.Audit VM.Clone VM.Config.CDROM VM.Config.Cloudinit VM.Config.CPU VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Migrate VM.Monitor VM.PowerMgmt User.Modify"

3. Assign the role to the previously created user:
    pveum aclmod / -user terraformAccess@pve -role Terraform

4. Create an API token for the user - SAVE THE TOKEN SECRET YOU SEE IN THE CLI: 
pveum user token add terraformAccess@pve provider-token --privsep=0


## example config
Example config.auto.tfvars
- 4 promox nodes
- node 1 has only 1 control_plane
- node 2 has 1 control_plane and 2 workers
- node 3 has 1 worker
```HCL
proxmox_api_url          = "https://192.168.1.100:8006/"
proxmox_user             = "terraform-prov@pve"
proxmox_api_token_id     = "provider"
proxmox_api_token_secret = "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"

talos_k8s_cluster_vip    = "192.168.1.101"
talos_k8s_cluster_name   = "azeroth"
talos_k8s_cluster_domain = "azeroth.local"
talos_network_cidr       = "192.168.1.0/24"
talos_network_gateway    = "192.168.1.1"
talos_network_ip_prefix  = "24"
talos_iso_destination_storage_pool = "truenas"


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

```