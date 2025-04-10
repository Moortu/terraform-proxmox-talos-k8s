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
  
  # Determine if we need to generate a random password
  need_random_password = var.argocd_admin_password == ""
  
  # Determine git URL based on provider
  git_url = var.git_url != "" ? var.git_url : (
             var.git_provider == "github" ? "https://github.com/${var.git_owner}/${var.git_repository}" : 
             var.git_provider == "gitlab" ? "https://gitlab.com/${var.git_owner}/${var.git_repository}" : ""
           )
}

# Generate random password if needed
resource "random_password" "argocd_admin" {
  count   = local.need_random_password ? 1 : 0
  length  = 16
  special = true
}

# ArgoCD namespace
resource "kubernetes_namespace" "argocd" {
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

# ArgoCD installation via Helm
resource "helm_release" "argocd" {
  depends_on = [kubernetes_namespace.argocd]

  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.argocd_version
  namespace  = var.argocd_namespace

  # Use create_namespace=false since we create it separately
  set {
    name  = "createNamespace"
    value = "false"
  }

  # Set admin password if provided or use generated one
  set_sensitive {
    name  = "configs.secret.argocdServerAdminPassword"
    value = local.need_random_password ? bcrypt(random_password.argocd_admin[0].result) : bcrypt(var.argocd_admin_password)
  }

  # Enable server features
  set {
    name  = "server.extraArgs"
    value = "{--insecure}"
  }

  # Configure Git repo credentials if token is provided
  dynamic "set" {
    for_each = var.git_token != "" ? [1] : []
    content {
      name  = "configs.repositories.${var.git_repository}.url"
      value = local.git_url
    }
  }
  
  dynamic "set" {
    for_each = var.git_token != "" ? [1] : []
    content {
      name  = "configs.repositories.${var.git_repository}.type"
      value = var.git_provider
    }
  }
  
  dynamic "set_sensitive" {
    for_each = var.git_token != "" ? [1] : []
    content {
      name  = "configs.repositories.${var.git_repository}.password"
      value = var.git_token
    }
  }
  
  dynamic "set" {
    for_each = var.git_token != "" ? [1] : []
    content {
      name  = "configs.repositories.${var.git_repository}.username"
      value = var.git_owner
    }
  }

  wait = var.wait_for_resources
}

# Set up Cilium as an ArgoCD Application if enabled
resource "local_file" "argocd_cilium_application" {
  count = var.cilium_enabled ? 1 : 0

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
  # Only suspend if Cilium is still managed by Talos inline manifests
  suspended: ${var.managed_by_talos}
EOT

  provisioner "local-exec" {
    command = <<-EOT
      export KUBECONFIG="${var.kubernetes_config_path}"
      kubectl apply -f "${path.root}/argocd/cilium-application.yaml"
    EOT
  }
}

# Display the ArgoCD admin password if we generated it
resource "null_resource" "display_argocd_password" {
  count = local.need_random_password ? 1 : 0
  
  depends_on = [helm_release.argocd]
  
  triggers = {
    password = random_password.argocd_admin[0].result
  }
  
  provisioner "local-exec" {
    command = "echo 'ArgoCD Admin Password: ${random_password.argocd_admin[0].result}'"
  }
}
