#### APP LOAD BALANCER CONFIGURATION ####

# Create loadbalancer
resource "openstack_lb_loadbalancer_v2" "app" {
  name          = "${var.identifier}-loadbalancer-app"
  vip_subnet_id = openstack_networking_subnet_v2.app.id
}

# Create listener
resource "openstack_lb_listener_v2" "app" {
  name            = "${var.identifier}-listener-app"
  protocol        = var.app_lb_protocol
  protocol_port   = var.app_port
  loadbalancer_id = openstack_lb_loadbalancer_v2.app.id
}

# Set method for load balance charge between instance
resource "openstack_lb_pool_v2" "app" {
  name        = "${var.identifier}-pool-app"
  protocol    = var.app_lb_protocol
  lb_method   = var.app_lb_algorithm
  listener_id = openstack_lb_listener_v2.app.id
}

# Add application instances to pool
resource "openstack_lb_member_v2" "app" {
  for_each      = var.app_instance_names
  name          = "${var.identifier}-member-${each.value}"
  address       = openstack_compute_instance_v2.app[each.value].access_ip_v4
  protocol_port = var.app_port
  pool_id       = openstack_lb_pool_v2.app.id
  subnet_id     = openstack_networking_subnet_v2.app.id
}

# Create health monitor for check services instances status
resource "openstack_lb_monitor_v2" "app" {
  name        = "${var.identifier}-monitor-app"
  pool_id     = openstack_lb_pool_v2.app.id
  type        = var.app_lb_protocol
  delay       = 5
  timeout     = 5
  max_retries = 5
}

# Assign a floating ip address to the load balancer pool
resource "openstack_networking_floatingip_v2" "appx" {
  pool       = var.public_network
  port_id    = openstack_lb_loadbalancer_v2.app.vip_port_id
  depends_on = [openstack_networking_router_interface_v2.app]
}


#### DB LOAD BALANCER CONFIGURATION ####

# Create loadbalancer
resource "openstack_lb_loadbalancer_v2" "db" {
  name          = "${var.identifier}-loadbalancer-db"
  vip_subnet_id = openstack_networking_subnet_v2.db.id
}

# Create listener
resource "openstack_lb_listener_v2" "db" {
  name            = "${var.identifier}-listener-db"
  protocol        = "TCP"
  protocol_port   = 3306
  loadbalancer_id = openstack_lb_loadbalancer_v2.db.id
}

# Set methode for load balance charge between instance
resource "openstack_lb_pool_v2" "db" {
  name        = "${var.identifier}-pool-db"
  protocol    = "TCP"
  lb_method   = var.database_lb_algorithm
  listener_id = openstack_lb_listener_v2.db.id

  persistence {
    type = "SOURCE_IP"
  }
}

# Add database instances to pool
resource "openstack_lb_member_v2" "db" {
  name          = "${var.identifier}-member-${tolist(var.db_instance_names)[0]}"
  address       = openstack_compute_instance_v2.db.access_ip_v4
  protocol_port = 3306
  pool_id       = openstack_lb_pool_v2.db.id
  subnet_id     = openstack_networking_subnet_v2.db.id
}

resource "openstack_lb_member_v2" "dbx" {
  for_each      = toset(slice(tolist(var.db_instance_names), 1, length(var.db_instance_names)))
  name          = "${var.identifier}-member-${each.value}"
  address       = openstack_compute_instance_v2.dbx[each.value].access_ip_v4
  protocol_port = 3306
  pool_id       = openstack_lb_pool_v2.db.id
  subnet_id     = openstack_networking_subnet_v2.db.id
}

# Create health monitor for check services instances status
resource "openstack_lb_monitor_v2" "db" {
  name        = "${var.identifier}-monitor-db"
  pool_id     = openstack_lb_pool_v2.db.id
  type        = "TCP"
  delay       = 5
  timeout     = 5
  max_retries = 5
}
