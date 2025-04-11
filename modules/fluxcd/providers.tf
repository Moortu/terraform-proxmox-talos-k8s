terraform {
  required_version = ">= 1.7.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.36.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.5.0"
    }
    github = {
      source  = "integrations/github"
      version = ">= 6.1"
    }
    flux = {
      source = "fluxcd/flux"
      version = "1.5.1"
    }
    # Only include the minimum required providers that are actually used in the module
    # Additional providers can be added if needed, but don't include ones that aren't used
  }
}
