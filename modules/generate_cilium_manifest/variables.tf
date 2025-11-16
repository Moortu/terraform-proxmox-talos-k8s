variable "cilium_version" {
  description = "Version of Cilium to deploy (see https://helm.cilium.io/)"
  type        = string
  default     = "1.18.4"
}

variable "use_kube_proxy" {
  description = "Whether to use kube-proxy. If false, Cilium will replace kube-proxy (kubeProxyReplacement=true)"
  type        = bool
  default     = false
}

variable "k8s_version" {
  description = "Kubernetes version for helm template compatibility (see https://kubernetes.io/releases/)"
  type        = string
  default     = "1.31.0"
}

variable "enable_bpf_masquerade" {
  description = <<-EOT
    Enable Cilium BPF masquerading (bpf.masquerade=true).
    
    IMPORTANT: This affects Talos DNS configuration!
    
    - false (default, Solution 2): Disable BPF masquerade to avoid DNS issues.
      Talos can keep forwardKubeDNSToHost=true (default).
      Falls back to iptables masquerading.
    
    - true (Solution 1): Enable BPF masquerade for better performance.
      REQUIRES setting forwardKubeDNSToHost=false in Talos machine config.
      Without this, CoreDNS will not work due to link-local address conflicts.
    
    See: https://github.com/siderolabs/talos/pull/9200
         https://github.com/cilium/cilium/issues/36761
  EOT
  type        = bool
  default     = false
}