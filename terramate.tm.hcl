terramate {
  required_version = ">= 0.4.0"
  
  config {
    git {
      default_branch = "main"
      default_remote = "origin"
      check_untracked   = false
      check_uncommitted = false
      check_remote      = false
    }
    
    run {
      env {
        # Ensure Terraform uses the stack directory as working directory
        TF_DATA_DIR = "${terramate.root.path.fs.absolute}${terramate.stack.path.absolute}/.terraform"
      }
    }
    
    experiments = ["outputs-sharing"]
  }
}

# Import global configuration
import {
  source = "./config/globals.tm.hcl"
}

sharing_backend "default" {
  type     = terraform
  filename = "_generated_shared.tm.tf"
  command  = ["tofu", "output", "-json"]
}

# Import provider generation configuration
import {
  source = "./config/generate_providers.tm.hcl"
}

# Import common variables generation configuration
import {
  source = "./config/generate_common_vars.tm.hcl"
}

# Import proxmox_nodes variable generation configuration
import {
  source = "./config/generate_proxmox_nodes_var.tm.hcl"
}

# Import TF_CLI_ARGS generation configuration
import {
  source = "./config/generate_tfvars_args.tm.hcl"
}
