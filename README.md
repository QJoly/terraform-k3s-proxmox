> :warning: This project uses a git submodule, you will need to clone it by adding the ”--recursive” option

# Terraform project to deploy a k3s

## Getting started

### Proxmox 
For the beginning, you will need to configure the way terraform will authenticate. (in `providers.tf`)
```tf
data "vault_generic_secret" "proxmox_host" {
  path = "kv/homelab"
}
provider "proxmox" {
  pm_api_url = data.vault_generic_secret.proxmox_host.data["proxmox_url"]
  pm_user    = data.vault_generic_secret.proxmox_host.data["proxmox_user"]

  pm_password = data.vault_generic_secret.proxmox_host.data["proxmox_password"]

  pm_tls_insecure = "true"
  pm_parallel     = 5
}
```

If you use vault as secret provider, you can just modify variables to match yours.
Otherwise, you have to specify the credentials directly in the file. (and delete the vault integration)

Ex: 
```tf
provider "proxmox" {
  pm_api_url = "https://localhost:8006/api2/json"
  pm_user    = "root@pam"
  pm_password = "MyHugePassword"
  pm_tls_insecure = "true"
  pm_parallel     = 5
}
```

Additionally, you need to specify storage pool, network interface and the node (even if you aren’t using multiple nodes) terraform will use to create virtual machines.
This information will be modifiable in `variables.tf`.

### Template 

Once virtual machines are created, we will connect to them using SSH. This requires authentication with private key (pre-configured). 

If your template does not have ssh pre-configured, please consider using the following template : [Debian-Template-Proxmox](https://github.com/QJoly/Debian-Template-Proxmox)

### Run terraform

Once everything is set up, you can run terraform with the following command: 
```bash 
terraform apply
```