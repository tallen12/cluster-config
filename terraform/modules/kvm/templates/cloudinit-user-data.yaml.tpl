#cloud-config
users:
  - default
  - name: ${ansible_user}
    # doas:
    #   - permit nopass ${ansible_user} as root
    passwd: "*"
    sudo: ALL=(ALL) NOPASSWD:ALL
    lock_passwd: true
    shell: /bin/bash
    ssh_authorized_keys:
      - ${ssh_key}
packages:
  - qemu-guest-agent
runcmd:
#   - rc-update add qemu-guest-agent
  - service qemu-guest-agent start
hostname: ${hostname}
