# kustomize cilium manifests
resource "local_file" "cilium_kustomization" {
  filename = "${path.module}/fluxcd/cilium/base/kustomization.yaml"
  content  = templatefile("${path.module}/fluxcd/cilium/base/kustomization.yaml.tpl", {
    cilium_version = var.cilium_version
  })
}

