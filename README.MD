Thanks to
[rgl/terraform-proxmox-talos](https://github.com/rgl/terraform-proxmox-talos) and especially [roeldev/iac-talos-cluster](https://github.com/roeldev/iac-talos-cluster) for inspiring.

# Getting started:
1. create a proxmox user with api token access #proxmox api token access setup 
2. create a vars.auto.tfvars file with your values # see example tfvars
3. terraform/tofu start
How to use:

create a vars.auto.tfvars and fill in the values you want


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
- if you specify a mac_address/ipaddress for a control_plane/worker, then that will be used instead of a random generated one.
- make sure that for the given talos_k8s_cluster_domain you have a dns record set in your dns resolver or hosts file

in create_talos-config, the qemu agent is used to retrieve all ipaddresses from control-planes, if you have more then 1 interface set up, it might break something, I haven't tested with more then 1 interface.

Through the config you can specify what vm's you want to run on what nodes and with what resources with high specificity.
For now the worker and control plane config is basically the same, but this might change in the future.

most variables in .tfvars are hoverable for description, but for the complex ones like proxmox_nodes you have to look it up yourself

## proxmox api token access setup:
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


## example config
Example config.auto.tfvars
- 4 promox nodes
- node 1 has only 1 control_plane
- node 2 has 1 control_plane and 2 workers
- node 3 has 1 worker
```HCL
proxmox_api_url          = "https://192.168.1.100:8006/"
proxmox_user             = "terraform-prov@pve"
proxmox_api_token_id     = "provider"
proxmox_api_token_secret = "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"

talos_k8s_cluster_vip    = "192.168.1.101"
talos_k8s_cluster_name   = "azeroth"
talos_k8s_cluster_domain = "azeroth.local"
talos_network_cidr       = "192.168.1.0/24"
talos_network_gateway    = "192.168.1.1"
talos_network_ip_prefix  = "24"
talos_iso_destination_storage_pool = "truenas"


proxmox_nodes = {
  pve-node-01 = {
    control_planes = [{
      name = "control-plane-01"
      node_labels = {
        role = "control-plane"
      }
      network_bridge         = "vmbr0"
      cpu_cores              = 4
      memory                 = 14
      boot_disk_size         = 100
      boot_disk_storage_pool = "local-lvm"
    }]
    workers = []
  }
  pve-node-02 = {
    control_planes = [{
      name = "control-plane-02"
      node_labels = {
        role = "control-plane"
      }
      network_bridge         = "vmbr0"
      cpu_cores              = 4
      memory                 = 14
      boot_disk_size         = 100
      boot_disk_storage_pool = "local-lvm"
    }]
    workers = [{
      name = "worker-01"
      node_labels = {
        role = "worker"
      }
      network_bridge         = "vmbr0"
      cpu_cores              = 4
      memory                 = 14
      boot_disk_size         = 100
      boot_disk_storage_pool = "local-lvm"
    },
    {
      name = "worker-02"
      node_labels = {
        role = "worker"
      }
      network_bridge         = "vmbr0"
      cpu_cores              = 4
      memory                 = 14
      boot_disk_size         = 100
      boot_disk_storage_pool = "local-lvm"
    }]
  }
  pve-node-03 = {
    control_planes = []
    workers = [{
      name = "worker-03"
      node_labels = {
        role = "worker"
      }
      network_bridge         = "vmbr0"
      cpu_cores              = 4
      memory                 = 14
      boot_disk_size         = 100
      boot_disk_storage_pool = "local-lvm"
    }]
  }
}

```