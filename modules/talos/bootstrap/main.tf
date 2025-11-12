terraform {
  required_providers {
    talos = {
      source = "siderolabs/talos"
    }
    time = {
      source = "opentofu/time"
    }
    local = {
      source = "hashicorp/local"
    }
  }
}

resource "talos_machine_bootstrap" "this" {
  client_configuration = var.client_configuration
  node                 = var.control_plane_nodes[0].ip
}

resource "time_sleep" "wait_for_bootstrap" {
  depends_on      = [talos_machine_bootstrap.this]
  create_duration = var.bootstrap_wait_duration
}

resource "talos_cluster_kubeconfig" "this" {
  depends_on           = [time_sleep.wait_for_bootstrap]
  client_configuration = var.client_configuration
  node                 = var.control_plane_nodes[0].ip
}

data "talos_client_configuration" "this" {
  depends_on           = [time_sleep.wait_for_bootstrap]
  cluster_name         = var.cluster_name
  client_configuration = var.client_configuration
  nodes                = [for node in var.control_plane_nodes : node.ip]
}

resource "local_sensitive_file" "talosconfig" {
  depends_on = [data.talos_client_configuration.this]
  content    = data.talos_client_configuration.this.talos_config
  filename   = "${path.root}/generated/talos/config"
}

resource "local_sensitive_file" "kubeconfig" {
  depends_on = [talos_cluster_kubeconfig.this]
  content    = talos_cluster_kubeconfig.this.kubeconfig_raw
  filename   = "${path.root}/generated/kube/config"
}
