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
    AZ_RESOURCE_GROUP_VNET_HUB=\(.AZ_RESOURCE_GROUP_VNET_HUB)
    hub_to_cluster=\(.hub_to_cluster)
    AZ_VNET_HUB_NAME=\(.AZ_VNET_HUB_NAME)
    "')"
    if [[ -z "${AZ_RESOURCE_GROUP_VNET_HUB}" ]]; then export AZ_RESOURCE_GROUP_VNET_HUB=none; fi
    if [[ -z "${hub_to_cluster}" ]]; then export hub_to_cluster=none; fi
    if [[ -z "${AZ_VNET_HUB_NAME}" ]]; then export AZ_VNET_HUB_NAME=none; fi
}

function getAddressSpaceForVNET() {
    local HUB_PEERED_VNET_JSON="$(az network vnet peering list \
        --resource-group "${AZ_RESOURCE_GROUP_VNET_HUB}" \
        --vnet-name "${AZ_VNET_HUB_NAME}")"
    local HUB_PEERED_VNET_EXISTING="$(echo "$HUB_PEERED_VNET_JSON" | jq --arg hub_to_cluster "${hub_to_cluster}" '.[] | select(.name==$hub_to_cluster)' | jq -r '.remoteAddressSpace.addressPrefixes[0]')"
    if [[ -n "$HUB_PEERED_VNET_EXISTING" ]]; then
        # vnet peering exist from before - use same IP
        local withoutCIDR=${HUB_PEERED_VNET_EXISTING%"/16"}
        echo "$withoutCIDR"
        return
    fi
}

function produce_output() {
    # Create a JSON object and pass it back
    jq -n \
        --arg AKS_VNET_ADDRESS_PREFIX "$(getAddressSpaceForVNET)" \
        '{"AKS_VNET_ADDRESS_PREFIX":$AKS_VNET_ADDRESS_PREFIX}'
}

# Main
check_deps
parse_input
produce_output
