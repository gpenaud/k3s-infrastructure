
resource "local_file" "ansible_inventory" {
  filename = "ansible/inventory"
  content = templatefile("files/inventory.tftpl", {
    hostnames = module.container.*.hostname,
    ips       = module.container.*.ip
    network   = var.network_name
  })
}

output "container_hostnames" {
  value = module.container.*.hostname
}

output "container_ips" {
  value = module.container.*.ip
}
