terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = ">=0.9"
    }
  }
}


provider "libvirt" {
  uri = "qemu+sshcmd://${var.ssh_user_for_host}@${var.ssh_host_for_host}/system?no_verify=1"
}

locals {
  hostname = "k3s-node-${var.node-id}"
}


resource "libvirt_volume" "alpine_disk" {
  name     = "k3s-node-${var.node-id}-volume.qcow2"
  pool     = "default"
  capacity = var.vm_disk_size

  target = {
    format = {
      type = "qcow2"
    }
    permissions = {
      owner = "64055"
      group = "108"
      mode  = "0775"
    }
  }
  
  backing_store = {
    path = var.snapshot_volume_path
    format = {
      type = "qcow2"
    }
  }
}

resource "libvirt_cloudinit_disk" "cloudinit" {
  name = "vm-init"

  user_data = templatefile("${path.module}/templates/cloudinit-user-data.yaml.tpl", {
    ssh_key = var.vm_public_key
    hostname    = local.hostname
    ansible_user = var.ansible_user
  })
  meta_data = templatefile("${path.module}/templates/cloudinit-metadata.yaml.tpl", {
    hostname    = local.hostname
  })
}


resource "libvirt_volume" "cloudinit_volume" {
  name = "k3s-node-${var.node-id}-cloudinit"
  pool = "default"

  target = {
    format = {
      type = "iso"
    }
  }

  create = {
    content = {
      url = libvirt_cloudinit_disk.cloudinit.path
    }
  }
}

resource "libvirt_domain" "vm" {
  name        = "k3s-node-${var.node-id}"
  memory      = var.vm_memory
  memory_unit = "MiB"
  vcpu        = var.vm_vcpu
  type        = "kvm"
  cpu = {
    mode = "host-passthrough"
  }
  os = {
    type         = "hvm"
    type_arch    = "x86_64"
    type_machine = "q35"
  }
  autostart = true
  running   = true
  devices = {
    channels = [{
      source = {
          unix = {} 
      }
      target = {
        virt_io = {
          name = "org.qemu.guest_agent.0"
        }
      }
    }]
    disks = [
      {
        device = "disk"
        source = {
          file = {
            file = libvirt_volume.alpine_disk.path
          }
        }
        driver = {
          type = "qcow2"
        }
        target = {
          dev = "vda"
          bus = "virtio"
        }
      },
      {
        device    = "cdrom"
        read_only = true
        source = {
          file = {
            file = libvirt_volume.cloudinit_volume.path
          }
        }
        target = {
          dev = "sda"
          bus = "sata"
        }
      }
    ]
    interfaces = [
      {
        type = "bridge"
        model = {
          type = "virtio"
        }
        source = {
          bridge = {
            bridge = "br0"
          }
        }
        wait_for_ip = {
          timeout = 300 # seconds
          source  = "agent"
        }
      }
    ]
  }
}
