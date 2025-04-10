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
  
  # Determine git URL based on provider
  git_url = var.git_provider == "github" ? "https://github.com/${var.git_owner}/${var.git_repository}" : (
             var.git_provider == "gitlab" ? (var.git_url != "" ? var.git_url : "https://gitlab.com/${var.git_owner}/${var.git_repository}") : 
             var.git_url
           )
}

# Flux system namespace
resource "kubernetes_namespace" "flux_system" {
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

# Flux CLI bootstrap command
resource "null_resource" "flux_bootstrap" {
  depends_on = [kubernetes_namespace.flux_system]

  triggers = {
    git_token       = var.git_token
    git_owner       = var.git_owner
    git_repo        = var.git_repository
    git_branch      = var.git_branch
    git_path        = var.git_path
    kubeconfig_path = var.kubernetes_config_path
    flux_version    = var.flux_version
    git_provider    = var.git_provider
    git_url         = local.git_url
  }

  provisioner "local-exec" {
    command = <<-EOT
      export KUBECONFIG="${var.kubernetes_config_path}"
      
      # First check if flux command exists
      if ! command -v flux &> /dev/null; then
        echo "Flux CLI not found, installing..."
        curl -s https://fluxcd.io/install.sh | bash
      fi
      
      # Bootstrap Flux based on Git provider
      %{if var.git_provider == "github"}
      export GITHUB_TOKEN="${var.git_token}"
      flux bootstrap github \
        --owner="${var.git_owner}" \
        --repository="${var.git_repository}" \
        --branch="${var.git_branch}" \
        --path="${var.git_path}" \
        --personal
      %{endif}
      
      %{if var.git_provider == "gitlab"}
      export GITLAB_TOKEN="${var.git_token}"
      flux bootstrap gitlab \
        --owner="${var.git_owner}" \
        --repository="${var.git_repository}" \
        --branch="${var.git_branch}" \
        --path="${var.git_path}" \
        ${var.git_url != "" ? "--hostname=${replace(replace(var.git_url, "https://", ""), "http://", "")}" : ""}
      %{endif}
      
      %{if var.git_provider == "gitea"}
      export GITEA_TOKEN="${var.git_token}"
      flux bootstrap git \
        --url="${local.git_url}" \
        --branch="${var.git_branch}" \
        --path="${var.git_path}"
      %{endif}
    EOT
  }
}

# Generate Cilium configuration for Flux if enabled
resource "local_file" "flux_cilium_repository" {
  count = var.cilium_enabled ? 1 : 0

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
      export KUBECONFIG="${var.kubernetes_config_path}"
      mkdir -p "${path.root}/flux/clusters/kalimdor/cilium"
      kubectl apply -f "${path.root}/flux/clusters/kalimdor/cilium/helmrepository.yaml"
    EOT
  }
}

resource "local_file" "flux_cilium_release" {
  count = var.cilium_enabled ? 1 : 0

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
  # Only suspend if Cilium is still managed by Talos inline manifests
  suspend: ${var.managed_by_talos}
EOT

  provisioner "local-exec" {
    command = <<-EOT
      export KUBECONFIG="${var.kubernetes_config_path}"
      kubectl apply -f "${path.root}/flux/clusters/kalimdor/cilium/release.yaml"
    EOT
  }
}
