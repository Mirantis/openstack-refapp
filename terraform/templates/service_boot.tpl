#!/bin/bash
set -x

SERVICE_TYPE=${service_type}
APP_DATABASE_NAME=${app_database_name}
APP_DATABASE_USER=${app_database_user}
APP_DATABASE_PASSWORD=${app_database_password}

%{ if service_type == "app" ~}
APP_DOCKER_IMAGE=${app_docker_image}
APP_PORT=${app_port}
DATABASE_VIP=${database_vip}
%{ else ~}
NODE_NUMBER=${node_number}
NODE_01_IP=${node_01_ip}
NODE_02_IP=${node_02_ip}
NODE_03_IP=${node_03_ip}
DATABASE_ADMIN_PASSWORD=${database_admin_password}
DATABASE_DISK=${database_disk}
DATABASE_DOCKER_IMAGE=${database_docker_image}
%{ endif ~}

source /tmp/.service_lib

case "$SERVICE_TYPE" in
    database)
        common_configuration
        mount_drives
        install_database
        ;;
    app)
        common_configuration
        install_app
        ;;
    *)
        echo "Unknown service type: $SERVICE_TYPE. Supported types are database or app"
        exit 1
esac
