# Generate Cilium manifests using helm template
# Following Talos best practices: https://docs.siderolabs.com/kubernetes-guides/cni/deploying-cilium
# These manifests should be used as inlineManifests in Talos machine configuration
#
# DNS CONFIGURATION - Choose one solution:
#
# Solution 2 (DEFAULT): enable_bpf_masquerade = false
#   - Cilium: bpf.masquerade=false (uses iptables)
#   - Talos: forwardKubeDNSToHost=true (default, keep DNS caching)
#
# Solution 1 (ADVANCED): enable_bpf_masquerade = true
#   - Cilium: bpf.masquerade=true (better performance)
#   - Talos: forwardKubeDNSToHost=false (REQUIRED in machine config)
#
# See: https://github.com/siderolabs/talos/pull/9200
#      https://github.com/cilium/cilium/issues/36761

locals {
  # Build values based on kube-proxy configuration
  base_values = {
    # IPAM mode must be kubernetes for Talos
    ipam = {
      mode = "kubernetes"
    }
    
    # Required security context capabilities for Talos
    securityContext = {
      capabilities = {
        ciliumAgent      = ["CHOWN", "KILL", "NET_ADMIN", "NET_RAW", "IPC_LOCK", "SYS_ADMIN", "SYS_RESOURCE", "DAC_OVERRIDE", "FOWNER", "SETGID", "SETUID"]
        cleanCiliumState = ["NET_ADMIN", "SYS_ADMIN", "SYS_RESOURCE"]
      }
    }
    
    # Cgroup configuration for Talos
    cgroup = {
      autoMount = {
        enabled = false
      }
      hostRoot = "/sys/fs/cgroup"
    }
    
    # BPF masquerading configuration
    # Solution 2 (default): bpf.masquerade=false to avoid DNS issues
    # Solution 1 (optional): bpf.masquerade=true requires forwardKubeDNSToHost=false in Talos
    # See: https://github.com/siderolabs/talos/pull/9200
    #      https://github.com/cilium/cilium/issues/36761
    bpf = {
      masquerade = var.enable_bpf_masquerade
    }
  }

  # Additional values when kube-proxy replacement is enabled
  kubeproxy_replacement_values = var.use_kube_proxy ? {} : {
    kubeProxyReplacement = "true"
    k8sServiceHost       = "localhost"
    k8sServicePort       = "7445"
  }

  # Merge all values
  cilium_values = merge(
    local.base_values,
    local.kubeproxy_replacement_values
  )
}

# Template the helm chart locally (no cluster connection needed)
data "helm_template" "cilium" {
  name       = "cilium"
  repository = "https://helm.cilium.io"
  chart      = "cilium"
  version    = var.cilium_version
  namespace  = "kube-system"
  
  values = [
    yamlencode(local.cilium_values)
  ]
  
  # Specify appropriate Kubernetes version
  kube_version = var.k8s_version
}