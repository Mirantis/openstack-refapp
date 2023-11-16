#### INSTANCE APPLICATION ####

data "template_file" "script" {
  for_each = var.app_instance_names
  template = file("templates/service_boot.tpl")

  vars = {
    service_type          = "app"
    database_vip          = openstack_lb_loadbalancer_v2.db.vip_address
    app_docker_image      = var.app_docker_image
    app_port              = var.app_port
    app_database_name     = var.app_database["name"]
    app_database_user     = var.app_database["user"]
    app_database_password = var.app_database["password"]
  }
}

data "template_file" "cloud_init" {
  template = file("templates/init.tpl")
  vars = {
    service_lib = filebase64("templates/service_lib")
  }
}

# Render a multi-part cloud-init config
data "template_cloudinit_config" "config" {
  for_each      = var.app_instance_names
  gzip          = true
  base64_encode = true

  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"
    content      = data.template_file.cloud_init.rendered
  }
  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.script[each.value].rendered
  }
}

# Create instance
resource "openstack_compute_instance_v2" "app" {
  for_each          = var.app_instance_names
  name              = "${var.identifier}-server-${each.value}"
  image_name        = var.image
  flavor_name       = var.flavor
  key_pair          = openstack_compute_keypair_v2.user_key.name
  user_data         = data.template_cloudinit_config.config[each.value].rendered
  availability_zone = var.app_instance_az
  tags              = local.server_tags
  network {
    port = openstack_networking_port_v2.app[each.value].id
  }

  provisioner "remote-exec" {
    connection {
      host        = openstack_networking_floatingip_v2.app[each.value].address
      user        = var.ssh["user_name"]
      private_key = file(var.ssh["private_key_file"])
    }
    inline = [
      "cloud-init status --wait"
    ]
  }
}

# Create network port
resource "openstack_networking_port_v2" "app" {
  for_each              = var.app_instance_names
  name                  = "${var.identifier}-port-${each.value}"
  network_id            = openstack_networking_network_v2.app.id
  admin_state_up        = true
  port_security_enabled = false
  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.app.id
  }
}

# Create floating ip
resource "openstack_networking_floatingip_v2" "app" {
  for_each   = var.app_instance_names
  pool       = var.public_network
  port_id    = openstack_networking_port_v2.app[each.value].id
  depends_on = [openstack_networking_router_interface_v2.app]
}
