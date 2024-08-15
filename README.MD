Thanks to
[rgl/terraform-proxmox-talos](https://github.com/rgl/terraform-proxmox-talos) and especially [roeldev/iac-talos-cluster](https://github.com/roeldev/iac-talos-cluster) for inspiring me.


mental order of terraform files (excluding vars and versions)
1. download_talos-iso.tf
2. init_vm_control-planes.tf
3. init_vm_workers.tf
4. create_talos-config.tf
5. boot_talos-nodes.tf


How to use:

```bash
#Create cluster
terraform init -upgrade
terraform plan #plan is optional
terraform apply -auto-approve

#Destory cluster
terraform destroy -auto-approve

# Recreate 
terraform destroy -auto-approve
terraform apply -auto-approve
```

Example config
- 3 promox nodes
- node 1 has only 1 control_plane
- node 2 has 1 control_plane and 2 workers
- node 3 has 1 worker
```HCL
proxmox_api_url = "https://192.168.1.101:8006/api2/json"
proxmox_user = "user@pve"
proxmox_api_token_id = "terraform-token"
proxmox_api_token_secret = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxxx"

talos_k8s_cluster_vip = "192.168.1.150"
talos_k8s_cluster_name = "talos-cluster"
talos_k8s_cluster_domain = "talos-cluster.local"

talos_iso_download_url = "https://factory.talos.dev/image/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515/v%version%/metal-amd64-secureboot.iso"
talos_iso_destination_storage_pool = "local-lvm"

talos_machine_install_image_url = "factory.talos.dev/installer-secureboot/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515:v%version%"


proxmox_nodes = {
  pve-01 = {
    control_planes = [{
        node_labels = {
            role = "control-plane"
        }
        network_bridge = "vmbr0"
        mac_address = "BC:00:11:26:58:D3"
        count = 1
        cpu_cores = 4
        memory = 14
        boot_disk_size = 100
        boot_disk_storage_pool = "local-lvm"
    }]
    workers = []
  }
  pve-02 = {
    control_planes = [{
        node_labels = {
            role = "control-plane"
        }
        network_bridge = "vmbr0"
        mac_address = "BC:00:11:3C:DA:48"
        count = 1
        cpu_cores = 4
        memory = 14
        boot_disk_size = 100
        boot_disk_storage_pool = "local-lvm"
    }]
    workers = [{
        node_labels = {
            role = "worker"
        }
        network_bridge = "vmbr0"
        mac_address = "BC:00:11:39:F5:3A"
        count = 1
        cpu_cores = 4
        memory = 14
        boot_disk_size = 100
        boot_disk_storage_pool = "local-lvm"
    },
    {
        node_labels = {
            role = "worker"
        }
        network_bridge = "vmbr0"
        mac_address = "BC:00:11:39:F5:3B"
        count = 1
        cpu_cores = 4
        memory = 14
        boot_disk_size = 100
        boot_disk_storage_pool = "local-lvm"
    }]
  }
  pve-03 = {
    control_planes = []
    workers = [{
        node_labels = {
            role = "worker"
        }
        network_bridge = "vmbr0"
        mac_address = "BC:00:11:39:F5:3A"
        count = 1
        cpu_cores = 4
        memory = 14
        boot_disk_size = 100
        boot_disk_storage_pool = "local-lvm"
    }]
  }
}

```