variable "cilium_version" {
  description = "Version of Cilium to deploy"
  type        = string
  default     = "1.15.6"
}

variable "use_kube_proxy" {
  description = "Whether to use kube-proxy (false for kubeProxyReplacement=true)"
  type        = bool
  default     = false
}

variable "k8s_version" {
  description = "Kubernetes version to use"
  type        = string
  default     = "1.31.0"
}