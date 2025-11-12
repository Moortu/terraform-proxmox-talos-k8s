variable "cilium_version" {
  description = "Version of Cilium to deploy"
  # https://helm.cilium.io/
  type        = string
  default     = "1.18.4"
}

variable "use_kube_proxy" {
  description = "Whether to use kube-proxy (false for kubeProxyReplacement=true)"
  type        = bool
  default     = false
}

variable "k8s_version" {
  description = "Kubernetes version to use"
  # https://kubernetes.io/releases/
  type        = string
  default     = "1.34.2"
}

variable "k8s_service_host" {
  description = "The Kubernetes service host"
  type        = string
  default     = "kubernetes.default.svc"
}

variable "k8s_service_port" {
  description = "The Kubernetes service port"
  type        = number
  default     = 443
}