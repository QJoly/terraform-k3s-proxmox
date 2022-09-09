terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = ">2.8.0"
    }
  }
}


module "master" {
    count = 1
    source = "github.com/QJoly/terraform-modules-proxmox"
    node_name = "master-${count.index}-tf"
    node_target = var.node
    node_qemuga = 1
    node_pool = "kubernetes"
    node_size_disk = "32G"
    node_bootauto = true
    node_template = "debian-11-tf"
    node_storage_disk = var.disk
    node_network_host = var.netint
    node_notes  = ""
    node_cpu    = 3
    node_memory = 3072
}


module "node" {
    count = 2
    source = "github.com/QJoly/terraform-modules-proxmox"
    node_name = "node-${count.index}-tf"
    node_target = var.node
    node_qemuga = 1
    node_pool = "kubernetes"
    node_size_disk = "32G"
    node_bootauto = true
    node_template = "debian-11-tf"
    node_storage_disk = var.disk
    node_network_host = var.netint
    node_notes  = ""
    node_cpu    = 3
    node_memory = 3072
}



resource "local_file" "inventory" {

    filename = "./inventory.ini"

    content     = <<_EOF
[master]
%{ for index, dns in module.master.*.vm_hostname ~}
${module.master[index].vm_hostname} ansible_host=${module.master[index].vm_ipaddress}
%{ endfor }
[node]
%{ for index, dns in module.node.*.vm_hostname ~}
${module.node[index].vm_hostname} ansible_host=${module.node[index].vm_ipaddress}
%{ endfor }

_EOF

 depends_on = [module.node,module.master]

}

resource "local_file" "inventory" {

    filename = "./ansible/k3s-ansible/inventory/sample/hosts.ini"

    content     = <<_EOF

[master]
%{ for index, dns in module.master.*.vm_hostname ~}
${module.master[index].vm_hostname} ansible_host=${module.master[index].vm_ipaddress}
%{ endfor }
[node]
%{ for index, dns in module.node.*.vm_hostname ~}
${module.node[index].vm_hostname} ansible_host=${module.node[index].vm_ipaddress}
%{ endfor }

[k3s_cluster:children]
master
node

_EOF

 depends_on = [module.node,module.master]

}

resource "null_resource" "playbooks"{
 depends_on = [module.node,module.master,local_file.inventory]
 for_each   = var.playbooks

 provisioner "local-exec" {
    when    = create
    command = "ANSIBLE_FORCE_COLOR=true ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook --timeout 30 -i inventory.ini ansible/${each.key} -v"
 }
}

resource "null_resource" "install_k3s"{
 depends_on = [module.node,module.master,local_file.inventory,null_resource.playbooks]

 provisioner "local-exec" {
    when    = create
    command = "ANSIBLE_FORCE_COLOR=true ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ansible/k3s-ansible/inventory/sample/hosts.ini ansible/k3s-ansible/site.yml -e ansible_user=root -v "
 }
}

