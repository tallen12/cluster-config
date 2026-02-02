terraform {
  required_providers {
    onepassword = {
      source  = "1password/onepassword"
      version = "~> 2.0"
    }
  }
}

provider "onepassword" {
  url = var.connect_url
  token = var.connect_token
}

data "onepassword_item" "ansible_user" {
  vault = "Development"
  title  = "Ansible User"
}


data "onepassword_item" "ansible_user_ssh" {
  vault = "Development"
  title  = "Ansible User SSH"
}



module "k3s-node-1" {
  source      = "../../modules/kvm"
  ssh_user_for_host = data.onepassword_item.ansible_user.username
  ssh_host_for_host    = "home-nas"
  vm_public_key   = data.onepassword_item.ansible_user_ssh.public_key
  node-id     = 1
  ansible_user = data.onepassword_item.ansible_user.username
}