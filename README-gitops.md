# GitOps Implementation Guide

This project supports flexible GitOps implementation for managing Kubernetes resources, with special attention to Cilium CNI deployment.

## GitOps Options

You can choose between three main deployment options:

1. **No GitOps**: Cilium deployed as inline manifests in Talos (default)
2. **FluxCD**: Cilium managed through FluxCD resources
3. **ArgoCD**: Cilium managed through ArgoCD resources
4. **Both**: Use both FluxCD and ArgoCD (typically for evaluation or migration)

## Configuration Variables

### GitOps Deployment Control

```hcl
# Control whether to include Cilium manifests in Talos or let GitOps tools manage them
include_cilium_inline_manifests = true  # Set to false when GitOps is ready to manage Cilium

# Choose which GitOps tool(s) to deploy
deploy_fluxcd = true  # Set to true to deploy FluxCD
deploy_argocd = false # Set to true to deploy ArgoCD, can be used alongside FluxCD if needed
```

### FluxCD Configuration

```hcl
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
```

### ArgoCD Configuration

```hcl
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
```

## Cilium Management Options

### Option 1: Talos Inline Manifests (Default)

This is the initial and default setup, where Cilium is deployed directly through Talos:

```hcl
include_cilium_inline_manifests = true
deploy_fluxcd = false
deploy_argocd = false
```

### Option 2: FluxCD-Managed Cilium

To transition to FluxCD-managed Cilium:

1. **Initial Setup (Transitional)**: 
   ```hcl
   include_cilium_inline_manifests = true
   deploy_fluxcd = true
   fluxcd_cilium_enabled = true
   ```
   This will deploy FluxCD with Cilium resources in suspended state.

2. **Complete Transition**:
   ```hcl
   include_cilium_inline_manifests = false
   deploy_fluxcd = true
   fluxcd_cilium_enabled = true
   ```
   This will disable inline manifests and allow FluxCD to take over.

### Option 3: ArgoCD-Managed Cilium

To transition to ArgoCD-managed Cilium:

1. **Initial Setup (Transitional)**:
   ```hcl
   include_cilium_inline_manifests = true
   deploy_argocd = true
   argocd_cilium_enabled = true
   ```
   This will deploy ArgoCD with Cilium Application in suspended state.

2. **Complete Transition**:
   ```hcl
   include_cilium_inline_manifests = false
   deploy_argocd = true
   argocd_cilium_enabled = true
   ```
   This will disable inline manifests and allow ArgoCD to take over.

## Transitioning Between Management Methods

The setup is designed to allow smooth transitions between Cilium management methods:

1. **From Inline to GitOps**:
   - Deploy the GitOps tool with `include_cilium_inline_manifests = true`
   - Once GitOps is correctly set up, change to `include_cilium_inline_manifests = false`
   - Terraform will automatically unsuspend the GitOps Cilium resources

2. **Between GitOps Tools**:
   - Set both `deploy_fluxcd = true` and `deploy_argocd = true`
   - Enable Cilium in one tool and disable in the other
   - Once confident in the new tool, disable the old one

3. **From GitOps to Inline**:
   - Set `include_cilium_inline_manifests = true` to enable inline manifests
   - Keep GitOps tool deployed temporarily with `*_cilium_enabled = false`
   - Once stable, set GitOps deployment to false if desired

## Git Provider Support

Both FluxCD and ArgoCD modules support multiple Git providers:

1. **GitHub**: Standard integration with personal access tokens
2. **GitLab**: Both gitlab.com and self-hosted instances
3. **Gitea**: Self-hosted Gitea instances

For self-hosted instances, use the appropriate `*_git_url` parameter.
