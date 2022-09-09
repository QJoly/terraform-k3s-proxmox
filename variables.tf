variable "node" {
	type = string
	default = "homelab-pve"
}

variable "netint" {
	type = string
	default = "vmbr0"
}

variable "disk" {
	type = string
	default = "local"
} 


variable "playbooks" {
 type = set(string)
 default = ["rename.yml","lvm.yml","k3s-adjustement.yml"]

}
