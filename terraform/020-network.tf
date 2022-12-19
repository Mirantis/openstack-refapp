#### NETWORK CONFIGURATION ####

# Router creation
data "openstack_networking_network_v2" "public" {
  name = var.public_network
}

resource "openstack_networking_router_v2" "generic" {
  name                = "${var.identifier}-router"
  external_network_id = data.openstack_networking_network_v2.public.id
}

#### APP NETWORK ####
resource "openstack_networking_network_v2" "app" {
  name = "${var.identifier}-network-app"
}

# Subnet app configuration
resource "openstack_networking_subnet_v2" "app" {
  name            = join("-", [var.identifier, var.app_network["subnet_name"]])
  network_id      = openstack_networking_network_v2.app.id
  cidr            = var.app_network["cidr"]
  dns_nameservers = var.dns_nameservers
}

# Router interface configuration
resource "openstack_networking_router_interface_v2" "app" {
  router_id = openstack_networking_router_v2.generic.id
  subnet_id = openstack_networking_subnet_v2.app.id
}

#### DB NETWORK ####
resource "openstack_networking_network_v2" "db" {
  name = "${var.identifier}-network-db"
}

# Subnet db configuration
resource "openstack_networking_subnet_v2" "db" {
  name            = join("-", [var.identifier, var.db_network["subnet_name"]])
  network_id      = openstack_networking_network_v2.db.id
  cidr            = var.db_network["cidr"]
  dns_nameservers = var.dns_nameservers
}

# Router interface configuration
resource "openstack_networking_router_interface_v2" "db" {
  router_id = openstack_networking_router_v2.generic.id
  subnet_id = openstack_networking_subnet_v2.db.id
}
