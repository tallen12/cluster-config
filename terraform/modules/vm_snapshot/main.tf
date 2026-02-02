terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = ">=0.9"
    }
  }
}


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

variable "snapshot_name" {
  description = "The name of the snapshot."
  type        = string
}

variable "snapshot_url" {
  description = "The url of the snapshot."
  type        = string
}


provider "libvirt" {
  uri = "qemu+sshcmd://${var.ssh_user_for_host}@${var.ssh_host_for_host}/system?no_verify=1"
}

resource "libvirt_volume" "snapshot" {
  name = var.snapshot_name
  pool = "default"

  target = {
    format = {
      type = "qcow2"
    }
  }

  create = {
    content = {
      url = var.snapshot_url
    }
    format = {
      type = "qcow2"
    }
  }

}

output "snapshot_volume" {
    value = libvirt_volume.snapshot
}