# Generate common variables used across multiple stacks
# This ensures version consistency and reduces duplication
generate_hcl "_generated_common_vars.tm.tf" {
  content {
    # Version variables - sourced from globals.tm.hcl
    variable "talos_version" {
      description = "Talos version to use"
      type        = tm_hcl_expression("string")
      default     = global.talos_version
    }
    
    variable "k8s_version" {
      description = "Kubernetes version to use"
      type        = tm_hcl_expression("string")
      default     = global.k8s_version
    }
    
    variable "cilium_version" {
      description = "Cilium version to use"
      type        = tm_hcl_expression("string")
      default     = global.cilium_version
    }
    
    variable "argocd_version" {
      description = "ArgoCD Helm chart version"
      type        = tm_hcl_expression("string")
      default     = global.argocd_version
    }
    
    # Network variables - common across multiple stacks
    variable "talos_network_cidr" {
      description = "Cluster nodes CIDR (e.g., 10.0.10.0/24)"
      type        = tm_hcl_expression("string")
    }
    
    variable "talos_network_gateway" {
      description = "Network gateway for Talos nodes"
      type        = tm_hcl_expression("string")
    }
    
    # Cluster configuration variables
    variable "talos_k8s_cluster_domain" {
      description = "Kubernetes cluster domain"
      type        = tm_hcl_expression("string")
      default     = "cluster.local"
    }
    
    variable "talos_k8s_cluster_vip_domain" {
      description = "Virtual IP domain for cluster"
      type        = tm_hcl_expression("string")
      default     = "talos-cluster.local"
    }
    
    variable "talos_k8s_cluster_endpoint_port" {
      description = "Kubernetes API endpoint port"
      type        = tm_hcl_expression("number")
      default     = 6443
    }
    
    variable "talos_k8s_cluster_vip" {
      description = "Virtual IP for Kubernetes API"
      type        = tm_hcl_expression("string")
    }
  }
}
