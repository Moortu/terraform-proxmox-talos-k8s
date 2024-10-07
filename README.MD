Thanks to
[rgl/terraform-proxmox-talos](https://github.com/rgl/terraform-proxmox-talos) and especially [roeldev/iac-talos-cluster](https://github.com/roeldev/iac-talos-cluster) for inspiring.


mental order of terraform files (excluding vars and versions)
1. download_talos_iso.tf
2. init_vm_control-planes.tf
3. init_vm_workers.tf
4. create_talos-config.tf
5. boot_talos-nodes.tf


How to use:

```bash
#Create cluster
tofu init -upgrade
tofu plan #plan is optional
tofu apply -auto-approve #auto-approve if you don't want to check the changes

#Destory cluster
tofu destroy -auto-approve

# Recreate 
tofu destroy -auto-approve
tofu apply -auto-approve
```

Network:
by default it uses random mac_addresses + dhcp
- if you turn dhcp off, network_dhcp = false, then it will take the network_cidr + control_plane_first_ip/worker_first_ip and generate ip's from there on.
- if you specify a mac_address for a control_plane/worker, then that will be used instead of a random generated one.

in create_talos-config, the qemu agent is used to retrieve all ipaddresses from control-planes, if you have more then 1 interface setup, it might break something

Through the config you can specify what vm's you want to run on what nodes and with what resources with high specificity.
For now the worker and control plane config is basically the same, but this might change in the future.

most variables in .tfvars are hoverable for description, but for the complex ones like proxmox_nodes you have to look it up yourself

proxmox api token access setup:
Instructions:
https://registry.terraform.io/providers/bpg/proxmox/latest/docs#api-token-authentication

in a shell on proxmox
1. Create a user:
pveum user add terraformAccess@pve

2. Create a role for the user - The list of privileges above is only an example atm
 pveum role add Terraform -privs "Datastore.Allocate Datastore.AllocateSpace Datastore.AllocateTemplate Datastore.Audit Pool.Allocate Sys.Audit Sys.Console Sys.Modify SDN.Use VM.Allocate VM.Audit VM.Clone VM.Config.CDROM VM.Config.Cloudinit VM.Config.CPU VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Migrate VM.Monitor VM.PowerMgmt User.Modify"

3. Assign the role to the previously created user:
    pveum aclmod / -user terraformAccess@pve -role Terraform

4. Create an API token for the user - SAVE THE TOKEN SECRET YOU SEE IN THE CLI: 
pveum user token add terraformAccess@pve provider-token --privsep=0


Example config.auto.tfvars
- 3 promox nodes
- node 1 has only 1 control_plane
- node 2 has 1 control_plane and 2 workers
- node 3 has 1 worker
```HCL
proxmox_api_url = "https://192.168.1.101:8006/"
proxmox_user = "terraformAccess@pve"
proxmox_api_token_id = "provider-token"
proxmox_api_token_secret = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxxx"

talos_k8s_cluster_vip = "192.168.1.150"
talos_k8s_cluster_name = "talos-cluster"
talos_k8s_cluster_domain = "talos-cluster.local"

talos_iso_download_url = "https://factory.talos.dev/image/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515/v%version%/metal-amd64-secureboot.iso"
talos_iso_destination_storage_pool = "local-lvm" #shared storage works better, otherwise you have to upload the image to every node storage

talos_machine_install_image_url = "factory.talos.dev/installer-secureboot/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515:v%version%"

# check vars-proxmox.tf for descriptions of each variable
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