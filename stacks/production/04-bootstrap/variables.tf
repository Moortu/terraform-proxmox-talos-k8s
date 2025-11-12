variable "talos_k8s_cluster_name" {
  type    = string
  default = "talos-cluster"
}

variable "talos_k8s_cluster_vip_domain" {
  type    = string
  default = "talos-cluster.local"
}

variable "talos_k8s_cluster_endpoint_port" {
  type    = number
  default = 6443
}

variable "talos_k8s_cluster_vip" {
  type = string
}

variable "talos_network_gateway" {
  type    = string
  default = "10.0.0.1"
}

variable "talos_network_ip_prefix" {
  type    = number
  default = 24
}

variable "talos_k8s_cluster_domain" {
  type    = string
  default = "cluster.local"
}

variable "deploy_fluxcd" {
  type    = bool
  default = false
}

variable "git_base_url" {
  type    = string
  default = "https://github.com"
}

variable "git_org_or_username" {
  type = string
}

variable "git_repository" {
  type = string
}

variable "git_username" {
  type = string
}

variable "git_token" {
  type      = string
  sensitive = true
}

variable "fluxcd_cluster_path" {
  type    = string
  default = "clusters/production"
}
