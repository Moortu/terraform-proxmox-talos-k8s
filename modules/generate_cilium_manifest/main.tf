# Generate cilium manifests using helm template
# This doesn't require a connection to the Kubernetes cluster
locals {
  cilium_values = {
    # 1. Core configuration for Talos with kube-proxy replacement
    kubeProxyReplacement = "true"
    k8sServiceHost = "localhost"
    k8sServicePort = "7445"
    
    
    # 3. Network device configuration (auto-detection for maximum portability)
    devices = ""
    
    # 4. Routing configuration (optimized for Talos)
    routingMode = "native"
    autoDirectNodeRoutes = true
    ipv4NativeRoutingCIDR = "10.244.0.0/16"
    
    # 5. DNS configuration (essential for external connectivity)
    dns = {
      enabled = true
      enableNodePort = true
    }
    
    # 6. Network masquerading and routing configuration
    bpf = {
      masquerade = true
    }
    
    # 7. External connectivity settings (optimized for kube-proxy replacement)
    externalIPs = {
      enabled = true
    }
    
    # 8. Gateway API support with enhanced protocol capabilities
    gatewayAPI = {
      enabled = true
      enableAlpn = true
      enableAppProtocol = true
    }
    
    # 9. Cgroup and BPF filesystem mounts (required for Talos)
    cgroup = {
      hostRoot = "/sys/fs/cgroup"
      autoMount = {
        enabled = false
      }
    }
    
    # 10. Critical connectivity settings for Talos
    ipv4 = {
      enabled = true
    }
    
    # 11. IPAM configuration (required for proper IP address management)
    ipam = {
      mode = "kubernetes"
    }
    
    # 12. Required security context capabilities for Talos
    securityContext = {
      capabilities = {
        ciliumAgent = ["CHOWN", "KILL", "NET_ADMIN", "NET_RAW", "IPC_LOCK", "SYS_ADMIN", "SYS_RESOURCE", "DAC_OVERRIDE", "FOWNER", "SETGID", "SETUID"]
        cleanCiliumState = ["NET_ADMIN", "SYS_ADMIN", "SYS_RESOURCE"]
      }
    }
    
    # 13. Envoy proxy configuration
    envoy = {
      enabled = true
    }
      
    # 14. Hubble configuration with correct cluster domain name
    hubble = {
      relay = {
        enabled = true
        # Use correct domain for your cluster
        peerTarget = "hubble-peer.kube-system.svc.k8s.kalimdor.lan:443"
      }
      ui = {
        enabled = true
      }
    }
  }
  
  # This will be exported for use in the machine configuration patch
  talos_patch = {
    cluster = {
      network = {
        cni = {
          name = "none"
        }
      }
      proxy = {
        disabled = true
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
  namespace = "kube-system"
  
  # Use values directly instead of dynamic sets
  values = [
    yamlencode(local.cilium_values)
  ]
  
  # Specify appropriate Kubernetes version - needs to be >=1.21.0
  kube_version = var.k8s_version
}

# Output the Cilium manifest to a file
resource "local_file" "cilium_manifest" {
  filename = "${path.root}/generated/cilium-manifest.yaml"
  content  = "${data.helm_template.cilium.manifest}"

  # Create the generated directory if it doesn't exist
  provisioner "local-exec" {
    command = "New-Item -Path '${dirname(self.filename)}' -ItemType Directory -Force"
    interpreter = ["PowerShell", "-Command"]
  }
}