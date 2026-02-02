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

resource "libvirt_volume" "alpine" {
  name = "alpine-3.22.2-base.qcow2"
  pool = "default"

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


  create = {
    content = {
      url = "https://dl-cdn.alpinelinux.org/alpine/v3.22/releases/cloud/generic_alpine-3.22.2-x86_64-bios-cloudinit-r0.qcow2"
    }
    format = {
      type = "qcow2"
    }
    permissions = {
      permissions = {
        owner = "64055"
        group = "108"
        mode  = "0775"
      }
    }
  }

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
    path = libvirt_volume.alpine.path
    format = {
      type = "qcow2"
    }
    permissions = {
      owner = "64055"
      group = "108"
      mode  = "0775"
    }
  }
}

resource "libvirt_cloudinit_disk" "cloudinit" {
  name = "vm-init"

  user_data = templatefile("${path.module}/templates/cloudinit-user-data.yaml.tpl", {
    ssh_key = var.vm_public_key
    node_id    = var.node-id
    ansible_user = var.ansible_user
  })
  meta_data = templatefile("${path.module}/templates/cloudinit-metadata.yaml.tpl", {
    node_id    = var.node-id
  })
}


resource "libvirt_volume" "cloudinit_volume" {
  name = "k3s-node-${var.node-id}-cloudinit"
  pool = "default"

  target = {
    format = {
      type = "iso"
    }
    permissions = {
      owner = "64055"
      group = "108"
      mode  = "0775"
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
          unix = {
            mode = "bind"
            path = "org.qemu.guest_agent.0"
        } 
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
