
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


