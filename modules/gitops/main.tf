locals {
  # Default common Cilium values based on the existing setup
  default_cilium_values = {
    ipam = {
      mode = "kubernetes"
    }
    kubeProxyReplacement = "true"
    securityContext = {
      capabilities = {
        ciliumAgent      = ["CHOWN", "KILL", "NET_ADMIN", "NET_RAW", "IPC_LOCK", "SYS_ADMIN", "SYS_RESOURCE", "DAC_OVERRIDE", "FOWNER", "SETGID", "SETUID"]
        cleanCiliumState = ["NET_ADMIN", "SYS_ADMIN", "SYS_RESOURCE"]
      }
    }
    cgroup = {
      autoMount = {
        enabled = false
      }
      hostRoot = "/sys/fs/cgroup"
    }
    k8sServiceHost = "localhost"
    k8sServicePort = "7445"
  }

  # Merge default values with any provided values
  cilium_values = merge(local.default_cilium_values, var.cilium_values)
  
  # Determine whether to deploy GitOps tools
  deploy_flux = var.gitops_type == "flux"
  deploy_argo = var.gitops_type == "argo"
}

# Flux installation
resource "kubernetes_namespace" "flux_system" {
  count = local.deploy_flux ? 1 : 0

  metadata {
    name = var.flux_namespace
  }

  lifecycle {
    ignore_changes = [
      metadata[0].labels,
      metadata[0].annotations,
    ]
  }
}

# ArgoCD installation
resource "kubernetes_namespace" "argocd" {
  count = local.deploy_argo ? 1 : 0

  metadata {
    name = var.argocd_namespace
  }

  lifecycle {
    ignore_changes = [
      metadata[0].labels,
      metadata[0].annotations,
    ]
  }
}

# Flux CLI bootstrap command
resource "null_resource" "flux_bootstrap" {
  count = local.deploy_flux ? 1 : 0

  depends_on = [kubernetes_namespace.flux_system]

  triggers = {
    github_token    = var.github_token
    github_owner    = var.github_owner
    github_repo     = var.github_repository
    github_branch   = var.github_branch
    github_path     = var.github_path
    kubeconfig_path = var.kubernetes_config_path
    flux_version    = var.flux_version
  }

  provisioner "local-exec" {
    command = <<-EOT
      export GITHUB_TOKEN="${var.github_token}"
      export KUBECONFIG="${var.kubernetes_config_path}"
      
      # First check if flux command exists
      if ! command -v flux &> /dev/null; then
        echo "Flux CLI not found, installing..."
        curl -s https://fluxcd.io/install.sh | bash
      fi
      
      # Bootstrap Flux
      flux bootstrap github \
        --owner="${var.github_owner}" \
        --repository="${var.github_repository}" \
        --branch="${var.github_branch}" \
        --path="${var.github_path}" \
        --personal
    EOT
  }
}

# ArgoCD installation via Helm
resource "helm_release" "argocd" {
  count = local.deploy_argo ? 1 : 0

  depends_on = [kubernetes_namespace.argocd]

  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.argocd_version
  namespace  = var.argocd_namespace

  values = [
    <<-EOT
    server:
      extraArgs:
        - --insecure
    configs:
      cm:
        timeout.reconciliation: 180s
      rbac:
        policy.default: role:readonly
    EOT
  ]

  wait = var.wait_for_resources
}

# Generate Cilium configuration for Flux if enabled
resource "local_file" "flux_cilium_repository" {
  count = local.deploy_flux && var.cilium_enabled ? 1 : 0

  depends_on = [null_resource.flux_bootstrap]

  filename = "${path.root}/flux/clusters/kalimdor/cilium/helmrepository.yaml"
  content  = <<-EOT
apiVersion: source.toolkit.fluxcd.io/v1beta2
kind: HelmRepository
metadata:
  name: cilium
  namespace: ${var.flux_namespace}
spec:
  interval: 1h
  url: https://helm.cilium.io
EOT

  provisioner "local-exec" {
    command = <<-EOT
      export KUBECONFIG=${var.kubernetes_config_path}
      mkdir -p ${path.root}/flux/clusters/kalimdor/cilium
      kubectl apply -f ${path.root}/flux/clusters/kalimdor/cilium/helmrepository.yaml
    EOT
  }
}

resource "local_file" "flux_cilium_release" {
  count = local.deploy_flux && var.cilium_enabled ? 1 : 0

  depends_on = [local_file.flux_cilium_repository]

  filename = "${path.root}/flux/clusters/kalimdor/cilium/release.yaml"
  content  = <<-EOT
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: cilium
  namespace: kube-system
spec:
  interval: 15m
  chart:
    spec:
      chart: cilium
      version: "${var.cilium_version}"
      sourceRef:
        kind: HelmRepository
        name: cilium
        namespace: ${var.flux_namespace}
  values: ${jsonencode(local.cilium_values)}
  # Initially suspended to avoid conflicts with Talos inline manifests
  suspend: true
EOT

  provisioner "local-exec" {
    command = <<-EOT
      export KUBECONFIG=${var.kubernetes_config_path}
      kubectl apply -f ${path.root}/flux/clusters/kalimdor/cilium/release.yaml
    EOT
  }
}

# Generate Cilium Application for ArgoCD if enabled
resource "local_file" "argocd_cilium_application" {
  count = local.deploy_argo && var.cilium_enabled ? 1 : 0

  depends_on = [helm_release.argocd]

  filename = "${path.root}/argocd/cilium-application.yaml"
  content  = <<-EOT
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cilium
  namespace: ${var.argocd_namespace}
spec:
  project: default
  source:
    repoURL: https://helm.cilium.io
    targetRevision: ${var.cilium_version}
    chart: cilium
    helm:
      values: |
        ${indent(8, yamlencode(local.cilium_values))}
  destination:
    server: https://kubernetes.default.svc
    namespace: kube-system
  syncPolicy:
    # Initially disabled to avoid conflicts with Talos inline manifests
    automated: null
EOT

  provisioner "local-exec" {
    command = <<-EOT
      export KUBECONFIG=${var.kubernetes_config_path}
      kubectl apply -f ${path.root}/argocd/cilium-application.yaml
    EOT
  }
}
