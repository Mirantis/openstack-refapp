#### INSTANCE DB ####

data "template_file" "script_db" {
  for_each = var.db_instance_names
  template = file("templates/service_boot.tpl")

  vars = {
    service_type            = "database"
    node_number             = trimprefix(each.value, "db-")
    node_01_ip              = openstack_networking_port_v2.db["db-01"].all_fixed_ips.0
    node_02_ip              = openstack_networking_port_v2.db["db-02"].all_fixed_ips.0
    node_03_ip              = openstack_networking_port_v2.db["db-03"].all_fixed_ips.0
    database_admin_password = var.db_admin_password
    database_disk           = var.db_disk
    app_database_name       = var.app_database["name"]
    app_database_user       = var.app_database["user"]
    app_database_password   = var.app_database["password"]
  }
}

data "template_file" "cloud_init_db" {
  template = file("templates/init.tpl")
  vars = {
    service_lib = filebase64("templates/service_lib")
  }
}

# Render a multi-part cloud-init config
data "template_cloudinit_config" "config_db" {
  for_each      = var.db_instance_names
  gzip          = true
  base64_encode = true

  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"
    content      = data.template_file.cloud_init_db.rendered
  }
  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.script_db[each.value].rendered
  }
}

# Create instance
resource "openstack_compute_instance_v2" "db" {
  name              = "${var.identifier}-server-${tolist(var.db_instance_names)[0]}"
  image_name        = var.image
  flavor_name       = var.flavor
  key_pair          = openstack_compute_keypair_v2.user_key.name
  user_data         = data.template_cloudinit_config.config_db["db-01"].rendered
  availability_zone = var.db_instance_az
  network {
    port = openstack_networking_port_v2.db["db-01"].id
  }

  provisioner "remote-exec" {
    connection {
      host        = openstack_networking_floatingip_v2.db["db-01"].address
      user        = var.ssh["user_name"]
      private_key = file(var.ssh["private_key_file"])
    }
    inline = [
      "cloud-init status --wait"
    ]
  }
}

resource "openstack_compute_instance_v2" "dbx" {
  for_each          = toset(slice(tolist(var.db_instance_names), 1, length(var.db_instance_names)))
  name              = "${var.identifier}-server-${each.value}"
  image_name        = var.image
  flavor_name       = var.flavor
  key_pair          = openstack_compute_keypair_v2.user_key.name
  user_data         = data.template_cloudinit_config.config_db[each.value].rendered
  availability_zone = var.db_instance_az
  network {
    port = openstack_networking_port_v2.db[each.value].id
  }
  depends_on = [openstack_compute_instance_v2.db]
}

# Create network port
resource "openstack_networking_port_v2" "db" {
  for_each              = var.db_instance_names
  name                  = "${var.identifier}-port-${each.value}"
  network_id            = openstack_networking_network_v2.db.id
  admin_state_up        = true
  port_security_enabled = false
  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.db.id
  }
}

# Create floating ip
resource "openstack_networking_floatingip_v2" "db" {
  for_each   = var.db_instance_names
  pool       = var.public_network
  port_id    = openstack_networking_port_v2.db[each.value].id
  depends_on = [openstack_networking_router_interface_v2.db]
}

#### VOLUME MANAGEMENT ####

# Create volume
resource "openstack_blockstorage_volume_v3" "db" {
  for_each = var.db_instance_names
  name     = "${var.identifier}-volume-${each.value}"
  size     = var.db_volume_size
}

# Attach volume to instance instance db
resource "openstack_compute_volume_attach_v2" "db" {
  instance_id = openstack_compute_instance_v2.db.id
  volume_id   = openstack_blockstorage_volume_v3.db["db-01"].id
  device      = var.db_disk
}

resource "openstack_compute_volume_attach_v2" "dbx" {
  for_each    = toset(slice(tolist(var.db_instance_names), 1, length(var.db_instance_names)))
  instance_id = openstack_compute_instance_v2.dbx[each.value].id
  volume_id   = openstack_blockstorage_volume_v3.db[each.value].id
  device      = var.db_disk
}
