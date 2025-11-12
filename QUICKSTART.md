# Terramate Quick Start Guide

## Prerequisites

1. **Install Terramate**

```bash
# Using Go
go install github.com/terramate-io/terramate/cmd/terramate@latest

# Or download binary from https://github.com/terramate-io/terramate/releases
# Extract and add to PATH
```

2. **Verify Installation**

```bash
terramate version
```

3. **Install Terraform/OpenTofu**

Ensure you have Terraform >= 1.7.0 or OpenTofu installed.

## Quick Deployment

### 1. Clone and Navigate

```bash
cd /home/kris/projects/terraform-proxmox-talos-k8s
```

### 2. Configure Your Environment

```bash
# Copy example configuration
cp example.tfvars stacks/production/cluster/terraform.tfvars

# Edit with your settings
nano stacks/production/cluster/terraform.tfvars
```

**Required changes:**
- `proxmox_api_url`
- `proxmox_user`
- `proxmox_api_token_id`
- `proxmox_api_token_secret`
- `talos_network_cidr`
- `talos_network_gateway`
- `talos_k8s_cluster_vip`
- `proxmox_nodes` configuration

### 3. Generate Terramate Code

```bash
terramate generate
```

This creates `_generated_providers.tf` in your stack.

### 4. Initialize and Deploy

```bash
# Navigate to the stack
cd stacks/production/cluster

# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Deploy
terraform apply
```

### Or Use Terramate Commands

From the project root:

```bash
# Initialize
terramate run terraform init

# Plan
terramate run terraform plan

# Apply
terramate run terraform apply
```

## Post-Deployment

### Access Your Cluster

```bash
# Kubeconfig is generated at:
export KUBECONFIG=./generated/kube/config

# Test access
kubectl get nodes
```

### Talos CLI

```bash
# Talosconfig is at:
export TALOSCONFIG=./generated/talos/config

# Check cluster health
talosctl health
```

## Project Structure

```
terraform-proxmox-talos-k8s/
├── terramate.tm.hcl              # Root Terramate config
├── config/                        # Global configuration
│   ├── globals.tm.hcl            # Global variables
│   ├── generate_providers.tm.hcl # Provider generation
│   └── generate_backend.tm.hcl   # Backend config
├── stacks/                        # Infrastructure stacks
│   └── production/
│       └── cluster/              # Main cluster stack
│           ├── stack.tm.hcl      # Stack definition
│           ├── main.tf           # Main configuration
│           ├── variables.tf      # Variables
│           ├── outputs.tf        # Outputs
│           ├── terraform.tfvars  # Your values
│           └── _generated_*.tf   # Auto-generated
└── modules/                       # Terraform modules
```

## Common Commands

### Terramate Commands

```bash
# List all stacks
terramate list

# List in execution order
terramate list --run-order

# Generate code
terramate generate

# Run command in all stacks
terramate run <command>

# Run in specific stack
terramate run --chdir stacks/production/cluster <command>

# Run only changed stacks (after git commit)
terramate run --changed <command>

# Parallel execution
terramate run --parallel 3 terraform plan
```

### Terraform Commands (in stack directory)

```bash
# Initialize
terraform init

# Plan
terraform plan

# Apply
terraform apply

# Destroy
terraform destroy

# Show outputs
terraform output

# Show state
terraform show
```

## Troubleshooting

### "No such file or directory: _generated_providers.tf"

Run code generation:
```bash
terramate generate
```

### "Module not found"

Ensure you're in the correct directory. Module paths are relative to the stack:
```bash
cd stacks/production/cluster
terraform init
```

### Variables Not Found

Check that `terraform.tfvars` exists in the stack directory and contains all required variables.

### Proxmox Connection Issues

Verify:
- Proxmox API URL is correct
- API token has correct permissions (PVEDatastoreUser, PVEVMAdmin)
- Network connectivity to Proxmox
- SSL certificate settings (insecure = true for self-signed)

## Next Steps

1. **Review the full migration guide**: See `TERRAMATE-MIGRATION.md`
2. **Customize your deployment**: Edit variables in `terraform.tfvars`
3. **Add more environments**: Copy `stacks/production` to `stacks/dev`
4. **Set up CI/CD**: Use Terramate change detection in your pipelines
5. **Configure remote state**: Edit `config/generate_backend.tm.hcl`

## Getting Help

- [Terramate Documentation](https://terramate.io/docs)
- [Talos Documentation](https://www.talos.dev)
- [Proxmox Provider Docs](https://registry.terraform.io/providers/bpg/proxmox/latest/docs)
