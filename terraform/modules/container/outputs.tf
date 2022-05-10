
output "hostname" {
  value = var.node_name
}

output "ip" {
  value = lxd_container.container.ipv4_address
}
