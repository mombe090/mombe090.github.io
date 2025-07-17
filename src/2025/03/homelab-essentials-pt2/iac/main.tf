locals {
  control_plane_patches = [
    templatefile("${path.module}/templates/config-patch.yaml.tftpl",
      { role = "controlplane" }
    )
  ]

  worker_patches = [
    templatefile("${path.module}/templates/config-patch.yaml.tftpl",
      { role = "worker" }
    )
  ]

  nodes = {
    "cp_1" = {
      id   = 200
      name = "conakry"
      ip   = "192.168.10.120"
      role = "controlplane"
      tags = ["controlplane", "talos", "kubernetes"]
    }
    "cp_2" = {
      id   = 300
      name = "dakar"
      ip   = "192.168.10.130"
      role = "controlplane"
      tags = ["controlplane", "talos", "kubernetes"]
    }
    "cp3" = {
      id   = 400
      name = "abidjan"
      ip   = "192.168.10.140"
      role = "controlplane"
      tags = ["controlplane", "talos", "kubernetes"]
    }
    "worker_1" = {
      id   = 201
      name = "kindia"
      ip   = "192.168.10.141"
      role = "worker"
      tags = ["worker", "talos", "kubernetes"]
    }
    "worker_2" = {
      id   = 202
      name = "boke"
      ip   = "192.168.10.142"
      role = "worker"
      tags = ["worker", "talos", "kubernetes"]
    }
    "worker_3" = {
      id   = 203
      name = "labe"
      ip   = "192.168.10.143"
      role = "worker"
      tags = ["worker", "talos", "kubernetes"]
    }
    "worker_4" = {
      id   = 204
      name = "kankan"
      ip   = "192.168.10.144"
      role = "worker"
      tags = ["worker", "talos", "kubernetes"]
    }
  }


}

##################################################
# Creation des machines virtuelles sur proxmox
#
##################################################
module "proxmox_vm" {
  for_each = local.nodes

  source = "git::https://github.com/mombe090/tf-modules//src/proxmox/vm?ref=v1.14.1"

  vm_id   = each.value.id
  vm_name = "${replace(each.key, "_", "-")}-${each.value.name}"

  cores     = each.value.role == "controlplane" ? 4 : 2
  memory    = 4090
  disk_size = 25

  vm_ip_address      = each.value.ip
  vm_gateway_address = "192.168.10.1"
  vm_nameservers     = []
  vm_search_domain   = ""

  tags = concat(each.value.tags, ["mombe090-blogs", "homelab"])
}


##################################################
# Creation du cluster Talos
#
##################################################
terraform {
  required_version = ">= 1.9.0"
}

module "talos" {
  source                    = "git::https://github.com/mombe090/tf-modules//src/talos?ref=v1.14.1"
  cluster_name              = "homelab-essentials"
  control_plane_ip          = local.nodes.cp_1.ip
  proxmox_server_ip_adresse = var.proxmox_server_ip

  nodes = {
    for k, v in local.nodes : k =>
    {
      ip      = v.ip
      role    = v.role
      patches = v.role == "controlplane" ? local.control_plane_patches : local.worker_patches
    }
  }
}
