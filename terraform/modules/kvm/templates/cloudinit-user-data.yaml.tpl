#cloud-config
users:
  - default
  - name: ${ansible_user}
    doas:
      - permit nopass ${ansible_user} as root
    passwd: "*"
    sudo: ALL=(ALL) NOPASSWD:ALL
    lock_passwd: false
    shell: /bin/ash
    ssh_authorized_keys:
      - ${ssh_key}
packages:
  - qemu-guest-agent
runcmd:
  - rc-update add qemu-guest-agent
  - service qemu-guest-agent start
hostname: k3s-node-${node_id}
