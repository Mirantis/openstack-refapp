# Configure Terraform

## Download and install terraform binary
Get the latest stable version:

    # wget -O- https://releases.hashicorp.com/terraform/1.3.7/terraform_1.3.7_linux_amd64.zip | funzip > /usr/bin/terraform
    # chmod +x /usr/bin/terraform

## Create instances ssh key
Generate keypairs for application/database instances:

    $ cd <openstack-refapp>/terraform
    $ ssh-keygen -N '' -f templates/.openstack

## Make providers init
The OpenStack provider needs to be configured with the proper credentials
before it can be used. They could be loaded from the environment variable names
(e.g. OS_*):

    $ export OS_CLOUD=admin
    $ terraform init

## Apply terraform state
Define passwords for database accounts and generate a speculative execution
plan, showing what actions would take to apply the current configuration, then
apply it:

    $ echo '{"db_passwords": {"admin": "<admin_password>", "app": "<app_password>"}}' > terraform.tfvars.json
    $ terraform plan
    $ terraform apply -auto-approve

> NOTE: The SSH keys by default have to be at templates/ dir of module with
> name of .openstack but it could be changed:

    $ terraform apply -var='ssh={"private_key_file":"<file_key>","public_key_file":"<file_key.pub>"}'

