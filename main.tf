locals {
  # get list of available addresses
  available_addresses_starte_range = 3
  available_addresses_end_range    = 255
  available_addresses_index_list   = [for i, el in range(local.available_addresses_starte_range, local.available_addresses_end_range) : "${i + local.available_addresses_starte_range}" if(contains(data.azurerm_virtual_network.hub.vnet_peerings_addresses, "10.${i + local.available_addresses_starte_range}.0.0/16") == false)]
  available_address                = local.available_addresses_index_list[0]
  # variables
  hub_to_cluster_name    = "hub-to-${var.CLUSTER_NAME}"
  AZ_IPPRE_OUTBOUND_NAME = "ippre-radix-aks-${var.CLUSTER_TYPE}-${var.AZ_LOCATION}-001"
}

data "azurerm_virtual_network" "hub" {
  name                = "vnet-hub"
  resource_group_name = var.AZ_RESOURCE_GROUP_VNET_HUB
}

data "external" "getAddressSpaceForVNET" {
  program = ["bash", "${path.module}/scripts/getAddressSpaceForVNET.sh"]
  query = {
    "AZ_RESOURCE_GROUP_VNET_HUB" = var.AZ_RESOURCE_GROUP_VNET_HUB,
    "hub_to_cluster"             = local.hub_to_cluster_name,
    "AZ_VNET_HUB_NAME"           = data.azurerm_virtual_network.hub.name
  }
}

data "external" "getPublicOutboundIps" {
  program = ["bash", "${path.module}/scripts/getPublicOutboundIps.sh"]
  query = {
    AZ_LOCATION              = var.AZ_LOCATION
    AZ_SUBSCRIPTION_ID       = var.AZ_SUBSCRIPTION_ID
    AZ_RESOURCE_GROUP_COMMON = var.AZ_RESOURCE_GROUP_COMMON
    CLUSTER_TYPE             = var.CLUSTER_TYPE
    MIGRATION_STRATEGY       = var.MIGRATION_STRATEGY
    OUTBOUND_IP_COUNT        = "1"
    AZ_IPPRE_OUTBOUND_NAME   = local.AZ_IPPRE_OUTBOUND_NAME
  }
}

resource "random_id" "four_byte" {
  byte_length = 4
}

resource "azurerm_kubernetes_cluster" "kubernetes_cluster" {
  depends_on = [
    azurerm_virtual_network.vnet_cluster
  ]

  name                            = var.CLUSTER_NAME
  location                        = var.AZ_LOCATION
  resource_group_name             = var.AZ_RESOURCE_GROUP_CLUSTERS
  dns_prefix                      = "${var.CLUSTER_NAME}-${random_id.four_byte.hex}"
  kubernetes_version              = var.AKS_KUBERNETES_VERSION
  local_account_disabled          = true
  sku_tier                        = "Paid"
  api_server_authorized_ip_ranges = length(var.WHITELIST_IPS) != 0 ? var.WHITELIST_IPS : null
  oidc_issuer_enabled             = true

  azure_active_directory_role_based_access_control {
    managed                = true
    admin_group_object_ids = ["a5dfa635-dc00-4a28-9ad9-9e7f1e56919d"]
  }

  default_node_pool {
    name                         = var.AKS_SYSTEM_NODE_POOL_NAME
    vm_size                      = var.AKS_NODE_POOL_VM_SIZE
    enable_auto_scaling          = true
    min_count                    = var.AKS_SYSTEM_NODE_MIN_COUNT
    max_count                    = var.AKS_SYSTEM_NODE_MAX_COUNT
    max_pods                     = 110
    os_disk_size_gb              = 128
    vnet_subnet_id               = azurerm_subnet.subnet_cluster.id
    node_labels                  = tomap({ nodepool-type = "system", nodepoolos = "linux", app = "system-apps" })
    only_critical_addons_enabled = true

  }

  identity {
    type         = "UserAssigned"
    identity_ids = [var.MI_AKS[0].id]
  }

  network_profile {
    network_plugin     = "azure"
    network_policy     = "calico"
    docker_bridge_cidr = "172.17.0.1/16"
    dns_service_ip     = "10.2.0.10"
    service_cidr       = "10.2.0.0/18"
    dynamic "load_balancer_profile" {
      for_each = var.MIGRATION_STRATEGY == "aa" ? [1] : []
      content {
        outbound_ip_address_ids  = data.external.getPublicOutboundIps.result.EGRESS_IP_ID_LIST
        outbound_ports_allocated = 4000
      }
    }
  }

  key_vault_secrets_provider {
    secret_rotation_enabled = true
  }

  kubelet_identity {
    client_id                 = var.MI_AKSKUBELET[0].client_id
    object_id                 = var.MI_AKSKUBELET[0].object_id
    user_assigned_identity_id = var.MI_AKSKUBELET[0].id
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "nodepools" {
  count = length(var.AKS_NODE_POOLS)

  name                  = var.AKS_NODE_POOLS[count.index].name
  kubernetes_cluster_id = var.AKS_NODE_POOLS[count.index].kubernetes_cluster_id
  vm_size               = var.AKS_NODE_POOLS[count.index].vm_size
  enable_auto_scaling   = true
  min_count             = var.AKS_NODE_POOLS[count.index].min_count
  max_count             = var.AKS_NODE_POOLS[count.index].max_count
  max_pods              = 110
  os_disk_size_gb       = 128
  mode                  = var.AKS_NODE_POOLS[count.index].mode
  vnet_subnet_id        = var.AKS_NODE_POOLS[count.index].vnet_subnet_id
  node_labels           = var.AKS_NODE_POOLS[count.index].node_labels
  node_taints           = var.AKS_NODE_POOLS[count.index].node_taints
}

resource "azurerm_virtual_network" "vnet_cluster" {
  # Wait on NSG
  depends_on = [
    azurerm_network_security_group.nsg_cluster
  ]

  name                = "vnet-${var.CLUSTER_NAME}"
  location            = var.AZ_LOCATION
  resource_group_name = var.AZ_RESOURCE_GROUP_CLUSTERS
  address_space       = data.external.getAddressSpaceForVNET.result.AKS_VNET_ADDRESS_PREFIX == "" ? ["10.${local.available_address}.0.0/16"] : ["${data.external.getAddressSpaceForVNET.result.AKS_VNET_ADDRESS_PREFIX}/16"]
}

resource "azurerm_virtual_network_peering" "cluster_to_hub" {
  name                         = "cluster-to-hub"
  resource_group_name          = var.AZ_RESOURCE_GROUP_CLUSTERS
  virtual_network_name         = azurerm_virtual_network.vnet_cluster.name
  remote_virtual_network_id    = data.azurerm_virtual_network.hub.id
  allow_virtual_network_access = true
}

resource "azurerm_virtual_network_peering" "hub_to_cluster" {
  name                         = local.hub_to_cluster_name
  resource_group_name          = var.AZ_RESOURCE_GROUP_VNET_HUB
  virtual_network_name         = data.azurerm_virtual_network.hub.name
  remote_virtual_network_id    = azurerm_virtual_network.vnet_cluster.id
  allow_virtual_network_access = true
}

resource "azurerm_subnet" "subnet_cluster" {
  name                 = "subnet-${var.CLUSTER_NAME}"
  resource_group_name  = var.AZ_RESOURCE_GROUP_CLUSTERS
  virtual_network_name = azurerm_virtual_network.vnet_cluster.name
  address_prefixes     = data.external.getAddressSpaceForVNET.result.AKS_VNET_ADDRESS_PREFIX == "" ? ["10.${local.available_address}.0.0/18"] : ["${data.external.getAddressSpaceForVNET.result.AKS_VNET_ADDRESS_PREFIX}/18"]
  service_endpoints    = ["Microsoft.Storage"]
}

resource "azurerm_network_security_group" "nsg_cluster" {
  name                = "nsg-${var.CLUSTER_NAME}"
  location            = var.AZ_LOCATION
  resource_group_name = var.AZ_RESOURCE_GROUP_CLUSTERS

  security_rule {
    name                    = "nsg-${var.CLUSTER_NAME}"
    priority                = "100"
    direction               = "Inbound"
    access                  = "Allow"
    protocol                = "Tcp"
    destination_port_ranges = ["80", "443"]
    # destination_address_prefix = azurerm_public_ip.pip_ingress.ip_address # AT
    destination_address_prefix = data.external.getPublicOutboundIps.result.EGRESS_IP_LIST
    source_port_range          = "*"
    source_address_prefix      = "*"
  }
}

# AT
resource "azurerm_public_ip" "pip_ingress" {
  # Check if AT or AA
  count               = var.MIGRATION_STRATEGY == "at" ? 1 : 0
  name                = "pip-radix-ingress-${var.RADIX_ZONE}-${var.RADIX_ENVIRONMENT}-${var.CLUSTER_NAME}"
  resource_group_name = var.AZ_RESOURCE_GROUP_COMMON
  location            = var.AZ_LOCATION
  allocation_method   = "Static"
  sku                 = "Standard"
  sku_tier            = "Regional"
}
