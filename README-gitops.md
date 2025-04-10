# GitOps Implementation Guide

This project supports flexible GitOps implementation for managing Kubernetes resources, with special attention to Cilium CNI deployment. The modular design allows you to choose your preferred GitOps tool(s) and transition smoothly between deployment methods.

## GitOps Options

You can choose between three main deployment options:

1. **No GitOps**: Cilium deployed as inline manifests in Talos (default)
   - Simplest option for getting started
   - Cilium manifests included directly in Talos machine configuration
   - Updates require reapplying Terraform/OpenTofu configuration
   
2. **FluxCD**: Cilium managed through FluxCD resources
   - Declarative, Git-based approach
   - Automated reconciliation of cluster state
   - Supports multiple Git providers and custom repository structures
   - Can manage its own updates after initial deployment
   
3. **ArgoCD**: Cilium managed through ArgoCD resources
   - UI-driven GitOps with strong visualization
   - Application-centric approach with dependency management
   - Supports multiple Git providers and custom repository structures
   - Can manage its own updates after initial deployment
   
4. **Both**: Use both FluxCD and ArgoCD (typically for evaluation or migration)
   - Useful for comparing tools or migrating between them
   - Allows gradual transition between GitOps solutions

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
   - Requires: Personal Access Token with `repo` scope
   - Example configuration:
     ```hcl
     fluxcd_git_provider = "github"
     fluxcd_git_token = "ghp_xxxxxxxxxxxxxxxxxxxx"
     fluxcd_git_owner = "yourusername"
     fluxcd_git_repository = "k8s-gitops"
     ```

2. **GitLab**: Both gitlab.com and self-hosted instances
   - Requires: Personal Access Token with `api`, `read_repository`, and `write_repository` scopes
   - For self-hosted instances, also specify the GitLab URL
   - Example configuration for self-hosted instance:
     ```hcl
     argocd_git_provider = "gitlab"
     argocd_git_token = "glpat-xxxxxxxxxxxxxxxxxxxx"
     argocd_git_owner = "yourusername"
     argocd_git_repository = "k8s-gitops"
     argocd_git_url = "https://gitlab.example.com"
     ```

3. **Gitea**: Self-hosted Gitea instances
   - Requires: Personal Access Token with appropriate permissions
   - Always requires the Gitea URL
   - Example configuration:
     ```hcl
     fluxcd_git_provider = "gitea"
     fluxcd_git_token = "gta_xxxxxxxxxxxxxxxxxxxx"
     fluxcd_git_owner = "yourusername"
     fluxcd_git_repository = "k8s-gitops"
     fluxcd_git_url = "https://gitea.example.com"
     ```

## Repository Structure Requirements

When using GitOps tools, you need to prepare your Git repository accordingly:

### For FluxCD

1. Create a repository for your GitOps configuration
2. The repository structure should align with your `fluxcd_git_path` setting (default: `clusters/<cluster-name>`)
3. Initial folder structure will be created by FluxCD bootstrap process
4. You can pre-create this structure with the following minimal layout:
   ```
   clusters/
     your-cluster-name/
       # FluxCD will populate this with configuration
   ```

### For ArgoCD

1. Create a repository for your GitOps configuration
2. The repository can follow any structure - ArgoCD will be configured to point to appropriate paths
3. A simple recommended structure:
   ```
   apps/
     cilium/
       # Cilium configuration will be placed here
     system/
       # System applications
     workloads/
       # Your workloads
   ```

## GitOps Self-Management Capabilities

Both FluxCD and ArgoCD can manage their own deployment after initial bootstrap:

### FluxCD Self-Management

After deployment, FluxCD can manage itself through the HelmRelease resource. This will be set up automatically if you deploy FluxCD with this project. Benefits:

- Update FluxCD version through Git commits
- Modify FluxCD configuration through GitOps workflow
- Add components or disable unused components

Example HelmRelease that will be created:
```yaml
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: flux-system
  namespace: flux-system
spec:
  chart:
    spec:
      chart: flux2
      sourceRef:
        kind: HelmRepository
        name: fluxcd
      version: 2.x.y  # Update this for new versions
  interval: 1h0m0s
  values:
    # Your FluxCD configuration
```

### ArgoCD Self-Management

ArgoCD can also manage itself through the Application resource. After initial deployment, you can:

- Update ArgoCD version through Git commits
- Add new components or features
- Customize the ArgoCD UI and experience

Example Application that will be created:
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: argocd
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://your-git-repo.git
    path: argocd/
    targetRevision: HEAD
  destination:
    server: https://kubernetes.default.svc
    namespace: argocd
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```
