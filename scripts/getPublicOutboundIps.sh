#!/usr/bin/env bash

function error_exit() {
    echo "$1" 1>&2
    exit 1
}

function check_deps() {
    test -f "$(which az)" || error_exit "az command not detected in path, please install it"
    test -f "$(which jq)" || error_exit "jq command not detected in path, please install it"
}

function parse_input() {
    eval "$(jq -r '@sh "
    AZ_LOCATION=\(.AZ_LOCATION)
    AZ_SUBSCRIPTION_ID=\(.AZ_SUBSCRIPTION_ID)
    AZ_RESOURCE_GROUP_COMMON=\(.AZ_RESOURCE_GROUP_COMMON)
    CLUSTER_TYPE=\(.CLUSTER_TYPE)
    MIGRATION_STRATEGY=\(.MIGRATION_STRATEGY)
    OUTBOUND_IP_COUNT=\(.OUTBOUND_IP_COUNT)
    AZ_IPPRE_OUTBOUND_NAME=\(.AZ_IPPRE_OUTBOUND_NAME)
    "')"
    if [[ -z "${AZ_LOCATION}" ]]; then export AZ_RESOURCE_GROUP_VNET_HUB=none; fi
    if [[ -z "${AZ_SUBSCRIPTION_ID}" ]]; then export hub_to_cluster=none; fi
    if [[ -z "${AZ_RESOURCE_GROUP_COMMON}" ]]; then export AZ_VNET_HUB_NAME=none; fi
    if [[ -z "${CLUSTER_TYPE}" ]]; then export AZ_VNET_HUB_NAME=none; fi
    if [[ -z "${MIGRATION_STRATEGY}" ]]; then export AZ_VNET_HUB_NAME=none; fi
    if [[ -z "${OUTBOUND_IP_COUNT}" ]]; then export AZ_VNET_HUB_NAME=none; fi
    if [[ -z "${AZ_IPPRE_OUTBOUND_NAME}" ]]; then export AZ_VNET_HUB_NAME=none; fi
}

# MIGRATION_STRATEGY outbound PIP assignment
# if migrating active to active cluster (eg. dev to dev)
# Path to Public IP Prefix which contains the public outbound IPs
IPPRE_EGRESS_ID="/subscriptions/$AZ_SUBSCRIPTION_ID/resourceGroups/$AZ_RESOURCE_GROUP_COMMON/providers/Microsoft.Network/publicIPPrefixes/$AZ_IPPRE_OUTBOUND_NAME"
# IPPRE_INGRESS_ID="/subscriptions/$AZ_SUBSCRIPTION_ID/resourceGroups/$AZ_RESOURCE_GROUP_COMMON/providers/Microsoft.Network/publicIPPrefixes/$AZ_IPPRE_INBOUND_NAME"

# list of AVAILABLE public EGRESS ips assigned to the Radix Zone
# echo "Getting list of available public egress ips in $RADIX_ZONE..."
AVAILABLE_EGRESS_IPS="$(az network public-ip list \
    --query "[?publicIPPrefix.id=='${IPPRE_EGRESS_ID}' && ipConfiguration.resourceGroup==null].{name:name, id:id, ipAddress:ipAddress}")"

# Select range of egress ips based on OUTBOUND_IP_COUNT
SELECTED_EGRESS_IPS="$(echo "$AVAILABLE_EGRESS_IPS" | jq '.[0:'$OUTBOUND_IP_COUNT']')"

function getPublicOutboundIpsIdList() {
    # Create the comma separated string of egress ip resource ids to pass in as --load-balancer-outbound-ips for aks
    while read -r line; do
        EGRESS_IP_ID_LIST+="${line},"
    done <<<"$(echo ${SELECTED_EGRESS_IPS} | jq -r '.[].id')"
    EGRESS_IP_ID_LIST=${EGRESS_IP_ID_LIST%,} # Remove trailing comma
    echo "${EGRESS_IP_ID_LIST}"
}

function getPublicOutboundIpsList() {
    # Create the comma separated string of egress ip resource ids to pass in as --load-balancer-outbound-ips for aks
    while read -r line; do
        EGRESS_IP_ID_LIST+="${line},"
    done <<<"$(echo ${SELECTED_EGRESS_IPS} | jq -r '.[].ipAddress')"
    EGRESS_IP_ID_LIST=${EGRESS_IP_ID_LIST%,} # Remove trailing comma
    echo "${EGRESS_IP_ID_LIST}"
}

function produce_output() {
    # Create a JSON object and pass it back
    jq -n \
        --arg EGRESS_IP_ID_LIST "$(getPublicOutboundIpsIdList)" \
        --arg EGRESS_IP_LIST "$(getPublicOutboundIpsList)" \
        '{"EGRESS_IP_ID_LIST":$EGRESS_IP_ID_LIST, "EGRESS_IP_LIST":$EGRESS_IP_LIST}'
}

# Main
check_deps
parse_input
produce_output
