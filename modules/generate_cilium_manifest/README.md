# Cilium Manifest Generator for Talos

This module generates Cilium CNI manifests using Helm templates, following [Talos best practices](https://docs.siderolabs.com/kubernetes-guides/cni/deploying-cilium).

## DNS Configuration Solutions

This module provides two solutions for the known DNS issue when using Talos with Cilium:

### Solution 2 (DEFAULT) - Disable BPF Masquerading

**Module Config:**
```hcl
module "cilium" {
  source = "./modules/generate_cilium_manifest"
  
  enable_bpf_masquerade = false  # default
}
```

**Talos Config:** (no changes needed, use defaults)
```yaml
machine:
  features:
    hostDNS:
      enabled: true
      forwardKubeDNSToHost: true  # default
```

**Trade-offs:**
- ✅ DNS works out of the box
- ✅ Maintains Talos DNS caching benefits
- ⚠️ Falls back to iptables for masquerading (slightly lower performance)

### Solution 1 (ADVANCED) - Enable BPF Masquerading

**Module Config:**
```hcl
module "cilium" {
  source = "./modules/generate_cilium_manifest"
  
  enable_bpf_masquerade = true  # enable for performance
}
```

**Talos Config:** (REQUIRED change)
```yaml
machine:
  features:
    hostDNS:
      enabled: true
      forwardKubeDNSToHost: false  # MUST disable this
```

**Trade-offs:**
- ✅ Full eBPF datapath with better performance
- ⚠️ Loses Talos host DNS caching benefits
- ⚠️ Requires explicit Talos configuration change

**References:**
- [Talos PR #9200 - Fix HostDNS link-local address](https://github.com/siderolabs/talos/pull/9200)
- [Cilium Issue #36761 - Link-local address unreachable](https://github.com/cilium/cilium/issues/36761)
- [Talos Cilium Known Issues](https://docs.siderolabs.com/kubernetes-guides/cni/deploying-cilium#known-issues)

## Usage

```hcl
module "cilium" {
  source = "./modules/generate_cilium_manifest"
  
  cilium_version        = "1.18.4"
  use_kube_proxy        = false  # Let Cilium replace kube-proxy
  k8s_version           = "1.31.0"
  enable_bpf_masquerade = false  # Solution 2 (recommended)
}

# Use the output in Talos machine configuration
output "cilium_manifests" {
  value     = module.cilium.cilium_manifests
  sensitive = false
}
```

## Talos Machine Configuration

When using this module, your Talos **control plane** machine configuration should include:

### With kube-proxy replacement (recommended)

```yaml
cluster:
  network:
    cni:
      name: none  # Cilium deployed via inlineManifests
    proxy:
      disabled: true  # Cilium replaces kube-proxy
  inlineManifests:
    - name: cilium
      contents: |
        # Paste cilium_manifests output here
```

### With kube-proxy

```yaml
cluster:
  network:
    cni:
      name: none  # Cilium deployed via inlineManifests
  inlineManifests:
    - name: cilium
      contents: |
        # Paste cilium_manifests output here
```

## Important Notes

1. **Only add inlineManifests to control plane nodes** - Worker nodes automatically use the CNI
2. **All control plane nodes must have identical configuration**
3. **Talos only creates missing resources** - it never deletes or updates inlineManifests
4. **To update manifests**: Edit all control plane configs and run `talosctl upgrade-k8s`

## Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `cilium_version` | Version of Cilium to deploy | `string` | `"1.18.4"` |
| `use_kube_proxy` | Whether to use kube-proxy (false = Cilium replaces it) | `bool` | `false` |
| `k8s_version` | Kubernetes version for Helm compatibility | `string` | `"1.31.0"` |
| `enable_bpf_masquerade` | Enable BPF masquerading (see DNS Solutions above) | `bool` | `false` |

## Outputs

| Name | Description |
|------|-------------|
| `cilium_manifests` | The generated Cilium manifests as YAML string |
| `cilium_version` | The version of Cilium being deployed |
| `cilium_values` | The Cilium values used for configuration |

## Cilium Configuration

The module automatically configures Cilium for Talos with:

- **IPAM mode**: `kubernetes` (required for Talos)
- **Security context**: Proper capabilities for Talos
- **Cgroup**: Configured for Talos cgroupv2
- **BPF masquerade**: Configurable (default: false)
- **Kube-proxy replacement**: When `use_kube_proxy = false`
  - Sets `k8sServiceHost` to `localhost`
  - Sets `k8sServicePort` to `7445` (Talos API server port)

## References

- [Talos Cilium CNI Guide](https://docs.siderolabs.com/kubernetes-guides/cni/deploying-cilium)
- [Cilium Helm Chart](https://helm.cilium.io/)
- [Cilium Documentation](https://docs.cilium.io/)
