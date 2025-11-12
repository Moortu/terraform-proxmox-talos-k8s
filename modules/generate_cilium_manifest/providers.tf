terraform {
  required_providers {
    helm = {
      source = "opentofu/helm"
    }
    kubernetes = {
      source = "opentofu/kubernetes"
    }
  }
}
