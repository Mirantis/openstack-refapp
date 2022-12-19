#!/bin/bash
set -x
# allow access to the local variables from prepare-metadata.py
set -a

#
# Variables in this block are passed from heat template
#
NODE_NUMBER=$node_number
NODE_01_IP=$node_01_ip
NODE_02_IP=$node_02_ip
NODE_03_IP=$node_03_ip
DATABASE_NETWORK_CIDR=$database_network_cidr
DATABASE_ADMIN_PASSWORD=$database_admin_password
DATABASE_VIP=$database_vip
DATABASE_DISK=$database_disk
SERVICE_TYPE=$service_type
APP_DOCKER_IMAGE=$app_docker_image
APP_PORT=$app_port
#
# End of block
#
DATABASE_ADMIN_PASSWORD=${DATABASE_ADMIN_PASSWORD:-"r00tme"}
DATABASE_DISK=${DATABASE_DISK:-"/dev/vdb"}
APP_DATABASE_NAME=${APP_DATABASE_NAME:-"refapp"}
APP_DATABASE_USER=${APP_DATABASE_USER:-"refapp"}
APP_DATABASE_PASSWORD=${APP_DATABASE_PASSWORD:-"refapp"}

function wait_condition_send {
    local status=${1:-SUCCESS}
    local reason=${2:-\"empty\"}
    local data=${3:-\"empty\"}
    local data_binary="{\"status\": \"$status\", \"reason\": \"$reason\", \"data\": $data}"
    echo "Trying to send signal to wait condition 5 times: $data_binary"
    WAIT_CONDITION_NOTIFY_EXIT_CODE=2
    i=0
    while (( ${WAIT_CONDITION_NOTIFY_EXIT_CODE} != 0 && ${i} < 5 )); do
        $wait_condition_notify -k --data-binary "$data_binary" && WAIT_CONDITION_NOTIFY_EXIT_CODE=0 || WAIT_CONDITION_NOTIFY_EXIT_CODE=2
        i=$((i + 1))
        sleep 1
    done
    if (( ${WAIT_CONDITION_NOTIFY_EXIT_CODE} !=0 && "${status}" == "SUCCESS" ))
    then
        status="FAILURE"
        reason="Can't reach metadata service to report about SUCCESS."
    fi
    if [ "$status" == "FAILURE" ]; then
        exit 1
    fi
}

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

wait_condition_send "SUCCESS" "Instance successfuly started."
