# Define local variables
locals {
  server_tags = ["openstack.lcm.mirantis.com:prober"]
}

# Define input variables

# Cluster
variable "identifier" {
  type    = string
  default = "refapp"
}
variable "image" {
  type        = string
  description = "Name of image to use for servers"
  default     = "Ubuntu-18.04"
}
variable "flavor" {
  type    = string
  default = "m1.tiny_test"
}
variable "public_network" {
  type    = string
  default = "public"
}
variable "dns_nameservers" {
  type    = list(string)
  default = []
}
variable "ssh" {
  type = map(string)
  default = {
    user_name        = "ubuntu"
    private_key_file = "templates/.openstack"
    public_key_file  = "templates/.openstack.pub"
  }
}

# Database
variable "db_instance_names" {
  type = set(string)
  default = [
    "db-01",
    "db-02",
    "db-03"
  ]
}
variable "db_instance_az" {
  type    = string
  default = "nova"
}
variable "db_network" {
  type        = map(string)
  description = "The details of database network"
  default = {
    subnet_name = "subnet-db"
    cidr        = "10.10.10.0/24"
  }
}
variable "db_passwords" {
  type        = map(string)
  description = "The passwords for database (admin,app)"
}
variable "db_disk" {
  type        = string
  description = "Dedicated disk for database"
  default     = "/dev/vdb"
}
variable "db_volume_size" {
  type        = number
  description = "Volume size of disk for database"
  default     = 1
}
variable "database_lb_provider" {
  type    = string
  default = "amphorav2"
  description = "The lb algorithm for database"
}
variable "database_lb_algorithm" {
  type        = string
  description = "LB algorithm for database"
  default     = "SOURCE_IP"
}


# Application
variable "app_instance_names" {
  type = set(string)
  default = [
    "app-01",
    "app-02",
    "app-03"
  ]
}
variable "app_instance_az" {
  type    = string
  default = "nova"
}
variable "app_network" {
  type        = map(string)
  description = "The details of application network"
  default = {
    subnet_name = "subnet-app"
    cidr        = "10.10.11.0/24"
  }
}
variable "app_docker_image" {
  type        = string
  description = "The link to docker image with App"
  default     = "mirantis.azurecr.io/openstack/openstack-refapp:0.1.13"
}
variable "app_port" {
  type    = number
  default = 8000
}
variable "app_database" {
  type        = map(string)
  description = "The credentials of application database"
  default = {
    name = "refapp"
    user = "refapp"
  }
}
variable "app_lb_algorithm" {
  type    = string
  default = "ROUND_ROBIN"
  description = "The lb algorithm for app"
}
variable "app_lb_provider" {
  type    = string
  default = "amphorav2"
  description = "The lb algorithm for app"
}
variable "app_lb_protocol" {
  type    = string
  default = "HTTP"
  description = "The lb protoco for app"
}
variable "database_docker_image" {
  type        = string
  description = "The link to docker image with Mairadb"
  default     = "mirantis.azurecr.io/openstack/extra/mariadb:10.6-focal"
}
