# Output application/database settings
output "database_network_id" {
  description = "The uuid of database network"
  value       = openstack_networking_network_v2.db.id
}
output "database_subnet_id" {
  description = "The uuid of database subnet"
  value       = openstack_networking_subnet_v2.db.id
}
output "app_network_id" {
  description = "The uuid of app network"
  value       = openstack_networking_network_v2.app.id
}
output "app_subnet_id" {
  description = "The uuid of app subnet"
  value       = openstack_networking_subnet_v2.app.id
}
output "database_private_ips" {
  description = "Private IP addresses of the deployed database instances"
  value       = values(openstack_networking_port_v2.db)[*].all_fixed_ips.0
}
output "database_floating_ips" {
  description = "Database instances floating IPs"
  value       = values(openstack_networking_floatingip_v2.db)[*].address
}
output "app_private_ips" {
  description = "Private IP addresses of the deployed app instances"
  value       = values(openstack_networking_port_v2.app)[*].all_fixed_ips.0
}
output "app_floating_ips" {
  description = "App instances floating IPs"
  value       = values(openstack_networking_floatingip_v2.app)[*].address
}
output "app_vip" {
  description = "VIP address of application"
  value       = openstack_networking_floatingip_v2.appx.address
}
output "app_url" {
  description = "API url for the reference application"
  value       = "http://${openstack_networking_floatingip_v2.appx.address}:${var.app_port}/"
}
