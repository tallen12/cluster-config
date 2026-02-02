output "hostname" {
    description = "Hostname for VM"
    value    = local.hostname
}

output "ip_address" {
    description = "IP address for VM"
    value    = libvirt_domain.vm
}