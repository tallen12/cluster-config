variable "ssh_user_for_host" {
  description = "The ssh user on the remote."
  type        = string
  sensitive = false
}

variable "ssh_host_for_host" {
  description = "The ssh host."
  type        = string
  sensitive = false
}

variable "ansible_user" {
  description = "The ansible user to configure for the vm in cloudinit."
  type        = string
  sensitive = false
}

variable "snapshot_volume_path" {
  description = "The path to the snapshot volume."
  type = string
}
variable "agent_channel_path_postfix" {
  description = "The path to the agent."
  type = string
  default = 0
}


variable "vm_public_key" {
  description = "SSH public key for user."
  type        = string
  sensitive = false
}

variable "node-id" {
  description = "The node id of the kvm instance."
  type        = string
  sensitive = false
}

variable "vm_memory" {
  description = "Memory for VM in MB."
  type        = number  
  default = 2048
}

variable "vm_disk_size" {
  description = "Disk for VM."
  type        = number  
  default = 21474836480
}

variable "vm_vcpu" {
  description = "CPUs for vm."
  type        = number  
  default = 2
}