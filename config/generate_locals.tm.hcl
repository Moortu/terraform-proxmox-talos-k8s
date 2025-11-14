# Generate common locals available in every stack
# These locals are derived from Terramate globals and stack metadata

generate_hcl "_generated_locals.tm.tf" {
  content {
    locals {
      tm_meta = {
        project      = tm_try(global.project_name, "terraform-proxmox-talos-k8s")
        environment  = tm_try(global.environment, terramate.stack.path.basename)
        stack_name   = terramate.stack.name
        name_prefix  = "${tm_try(global.project_name, "proj")}-${tm_try(global.environment, "env")}-${terramate.stack.name}"
        tags = merge(
          tm_try(global.default_tags, {}),
          {
            project     = tm_try(global.project_name, "proj")
            environment = tm_try(global.environment, terramate.stack.path.basename)
            stack       = terramate.stack.name
          }
        )
      }

      tm_versions = {
        talos      = tm_try(global.talos_version, "1.11.5")
        kubernetes = tm_try(global.k8s_version, "1.34.2")
        cilium     = tm_try(global.cilium_version, "1.18.4")
      }
    }
  }
}
