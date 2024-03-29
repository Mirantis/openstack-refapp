provider "openstack" {
  use_octavia = "true"
  cloud = "admin"
}

# Define OpenStack provider
terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.53.0"
    }
  }
}
