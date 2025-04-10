# Generate cilium manifests using helm template
# This doesn't require a connection to the Kubernetes cluster
locals {
  cilium_values = {
    ipam = {
      mode = "kubernetes"
    }
    kubeProxyReplacement = var.use_kube_proxy ? "false" : "true"
    securityContext = {
      capabilities = {
        ciliumAgent = ["CHOWN", "KILL", "NET_ADMIN", "NET_RAW", "IPC_LOCK", "SYS_ADMIN", "SYS_RESOURCE", "DAC_OVERRIDE", "FOWNER", "SETGID", "SETUID"]
        cleanCiliumState = ["NET_ADMIN", "SYS_ADMIN", "SYS_RESOURCE"]
      }
    }
    cgroup = {
      autoMount = {
        enabled = false
      }
      hostRoot = "/sys/fs/cgroup"
    }
  }
  
  # Add these settings only when not using kube-proxy
  kube_proxy_replacement_values = var.use_kube_proxy ? {} : {
    k8sServiceHost = "localhost"
    k8sServicePort = "7445"
  }
  
  # Merge all values
  all_values = merge(local.cilium_values, local.kube_proxy_replacement_values)
  
  # This will be exported for use in the machine configuration patch
  talos_patch = {
    cluster = {
      network = {
        cni = {
          name = "none"
        }
      }
      proxy = {
        disabled = var.use_kube_proxy ? false : true
      }
    }
  }
}

# Template the helm chart locally
data "helm_template" "cilium" {
  name       = "cilium"
  repository = "https://helm.cilium.io"
  chart      = "cilium"
  version    = var.cilium_version
  
  # Use values directly instead of dynamic sets
  values = [
    yamlencode(local.all_values)
  ]
  
  # Specify appropriate Kubernetes version - needs to be >=1.21.0
  kube_version = var.k8s_version
}