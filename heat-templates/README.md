# Launch the stack with refapp

## Prepare to create the stack
The OpenStack client needs to be configured with the proper credentials
before it can be used. They could be loaded from the environment variable names
(e.g. OS_*):

    $ export OS_CLOUD=admin

Check out target heat stack doesn't exist:

    $ STACK_NAME=refapp
    $ openstack stack check $STACK_NAME

Pick an appropriate flavor/image/etc if defaults are not suitable:

    $ openstack flavor list
    $ openstack image list

## Create instances ssh key
Generate keypairs for application/database instances:

    $ cd <openstack-refapp>/heat-templates
    $ ssh-keygen -N '' -C '' -f .openstack

## Create the stack
Lets create the stack, using a refapp template with passwords for database
accounts and public key generated above:

    $ PUBLIC_KEY=$(<.openstack.pub)
    $ PRIVATE_KEY=$(<.openstack)
    $ openstack stack create -t top.yaml --parameter "cluster_public_key=${PUBLIC_KEY}" \
      --parameter "cluster_private_key=${PRIVATE_KEY}" \
      --parameter "database_admin_password=<admin_password>" \
      --parameter "app_database_password=<app_password>" $STACK_NAME

## Verify stack creation

Since the refapp takes some time to install, it could be a few minutes before
application instances is in a running state:

    $ openstack stack event list $STACK_NAME
    $ openstack stack resource list $STACK_NAME
    $ openstack stack show $STACK_NAME

## Get URL of installed application

    $ openstack stack output show $STACK_NAME app_url
