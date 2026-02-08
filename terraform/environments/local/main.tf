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


module "alpine_snapshot_home_nas" {
  source      = "../../modules/vm_snapshot"
  ssh_user_for_host = data.onepassword_item.ansible_user.username
  ssh_host_for_host    = "home-nas"
  snapshot_name = "ubuntu"
  snapshot_url = "https://cloud-images.ubuntu.com/resolute/current/resolute-server-cloudimg-amd64.img"
}

module "alpine_snapshot_sakiko" {
  source      = "../../modules/vm_snapshot"
  ssh_user_for_host = data.onepassword_item.ansible_user.username
  ssh_host_for_host    = "sakiko-server"
  snapshot_name = "ubuntu"
  snapshot_url = "https://cloud-images.ubuntu.com/resolute/current/resolute-server-cloudimg-amd64.img"

}

# Should run the ansible playbook to setup the ansible ssh user on the VM hosts 
module "k3s-node-1" {
  source      = "../../modules/kvm"
  ssh_user_for_host = data.onepassword_item.ansible_user.username
  ssh_host_for_host    = "home-nas"
  vm_public_key   = data.onepassword_item.ansible_user_ssh.public_key
  node-id     = "tomori"
  ansible_user = data.onepassword_item.ansible_user.username
  snapshot_volume_path = module.alpine_snapshot_home_nas.snapshot_volume.path
}

module "k3s-node-2" {
  source      = "../../modules/kvm"
  ssh_user_for_host = data.onepassword_item.ansible_user.username
  ssh_host_for_host    = "sakiko-server"
  vm_public_key   = data.onepassword_item.ansible_user_ssh.public_key
  node-id     = "sakiko"
  ansible_user = data.onepassword_item.ansible_user.username
  snapshot_volume_path = module.alpine_snapshot_sakiko.snapshot_volume.path
}

module "k3s-node-3" {
  source      = "../../modules/kvm"
  ssh_user_for_host = data.onepassword_item.ansible_user.username
  ssh_host_for_host    = "home-nas"
  vm_public_key   = data.onepassword_item.ansible_user_ssh.public_key
  node-id     = "anon"
  ansible_user = data.onepassword_item.ansible_user.username
  snapshot_volume_path = module.alpine_snapshot_home_nas.snapshot_volume.path
  agent_channel_path_postfix = 1
}

output "test_output" {
  value = [
    module.k3s-node-1.hostname,
    module.k3s-node-2.hostname,
    module.k3s-node-3.hostname
  ]
}