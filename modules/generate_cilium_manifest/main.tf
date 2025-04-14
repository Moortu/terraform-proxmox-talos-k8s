# Generate cilium manifests using helm template
# This doesn't require a connection to the Kubernetes cluster
locals {
  cilium_values = {
    ipam = {
      mode = "kubernetes"
    }
    kubeProxyReplacement = "true" 
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
   
    # Envoy proxy settings
    envoy = {
      enabled = true
    }
    # Hubble monitoring settings
    hubble = {
      relay = {
        enabled = true
      }
      ui = {
        enabled = true
      }
    }
    k8sServiceHost = "localhost"
    k8sServicePort = "7445"
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