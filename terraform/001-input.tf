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
variable "db_admin_password" {
  type        = string
  description = "The root password for database"
  default     = "r00tme"
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
  default     = "mirantis.azurecr.io/openstack/openstack-refapp:0.1.1"
}
variable "app_port" {
  type    = number
  default = 8000
}
variable "app_database" {
  type        = map(string)
  description = "The credentials of application database"
  default = {
    name     = "refapp"
    user     = "refapp"
    password = "refapp"
  }
}
