data "azurerm_virtual_network" "hub" {
  name                = "vnet-hub"
  resource_group_name = local.AZ_RESOURCE_GROUP_VNET_HUB
}

resource "random_id" "this" {
  byte_length = 4
}

locals {
  AZ_RESOURCE_GROUP_VNET_HUB = "cluster-vnet-hub-dev"
}

resource "azurerm_kubernetes_cluster" "this" {
  depends_on = [
    azurerm_virtual_network.this
  ]

  name                            = var.cluster_name
  location                        = var.AZ_LOCATION
  resource_group_name             = var.AZ_RESOURCE_GROUP_CLUSTERS
  dns_prefix                      = "${var.cluster_name}-${random_id.this.hex}"
  kubernetes_version              = var.aks_kubernetes_version
  local_account_disabled          = true
  sku_tier                        = "Paid"
  api_server_authorized_ip_ranges = length(var.whitelist_ips) != 0 ? var.whitelist_ips : null

  azure_active_directory_role_based_access_control {
    managed                = true
    admin_group_object_ids = ["a5dfa635-dc00-4a28-9ad9-9e7f1e56919d"]
  }

  default_node_pool {
    name                = var.aks_node_pool_name
    vm_size             = var.aks_node_pool_vm_size
    node_count          = var.aks_node_count
    enable_auto_scaling = true
    min_count           = 2
    max_count           = 5
    max_pods            = 110
    os_disk_size_gb     = 128
    vnet_subnet_id      = azurerm_subnet.this.id
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

resource "azurerm_virtual_network" "this" {
  # Wait on NSG
  depends_on = [
    azurerm_network_security_group.this
  ]

  name                = "vnet-${var.cluster_name}"
  location            = var.AZ_LOCATION
  resource_group_name = var.AZ_RESOURCE_GROUP_CLUSTERS
  address_space       = ["10.9.0.0/16"] # get address_space from vnet-hub
}

resource "azurerm_virtual_network_peering" "this" {
  name                         = "hub-to-${var.cluster_name}"
  resource_group_name          = local.AZ_RESOURCE_GROUP_VNET_HUB
  virtual_network_name         = data.azurerm_virtual_network.hub.name
  remote_virtual_network_id    = azurerm_virtual_network.this.id
  allow_virtual_network_access = true
}

resource "azurerm_subnet" "this" {
  name                 = "subnet-${var.cluster_name}"
  resource_group_name  = var.AZ_RESOURCE_GROUP_CLUSTERS
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.9.0.0/18"] # get address_space from vnet-hub
}

resource "azurerm_network_security_group" "this" {
  name                = "nsg-${var.cluster_name}"
  location            = var.AZ_LOCATION
  resource_group_name = var.AZ_RESOURCE_GROUP_CLUSTERS

  security_rule {
    name                       = "nsg-${var.cluster_name}"
    priority                   = "100"
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    destination_port_ranges    = ["80", "443"]
    destination_address_prefix = azurerm_public_ip.this.ip_address
    source_port_range          = "*"
    source_address_prefix      = "*"
  }
}

resource "azurerm_public_ip" "this" {
  name                = "pip-radix-ingress-${var.RADIX_ZONE}-${var.RADIX_ENVIRONMENT}-${var.cluster_name}"
  resource_group_name = var.AZ_RESOURCE_GROUP_COMMON
  location            = var.AZ_LOCATION
  allocation_method   = "Static"
  sku                 = "Standard"
  sku_tier            = "Regional"
}

resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  count                 = length(var.AZ_PRIVATE_DNS_ZONES)
  name                  = "${var.cluster_name}-link"
  resource_group_name   = local.AZ_RESOURCE_GROUP_VNET_HUB
  private_dns_zone_name = var.AZ_PRIVATE_DNS_ZONES[count.index]
  virtual_network_id    = azurerm_virtual_network.this.id
  registration_enabled  = false
}

resource "azurerm_redis_cache" "this" {
  count = length(var.RADIX_WEB_CONSOLE_ENVIRONMENTS)

  name                          = "${var.cluster_name}-${var.RADIX_WEB_CONSOLE_ENVIRONMENTS[count.index]}"
  resource_group_name           = var.AZ_RESOURCE_GROUP_CLUSTERS
  location                      = var.AZ_LOCATION
  capacity                      = "1"
  family                        = "C"
  sku_name                      = "Basic"
  public_network_access_enabled = true
  redis_configuration {
    maxmemory_reserved              = "125"
    maxfragmentationmemory_reserved = "125"
    maxmemory_delta                 = "125"
  }
}

# data "azurerm_container_registry" "this" {
#   name                = "radixdev"
#   AZ_RESOURCE_GROUP_CLUSTERS = var.AZ_RESOURCE_GROUP_COMMON
# }

# Resource already exist and for safety we don't import it. We take this in use later.
# resource "azurerm_role_assignment" "this" {
#   principal_id                     = var.MI_AKSKUBELET[0].object_id
#   role_definition_name             = "AcrPull"
#   scope                            = data.azurerm_container_registry.this.id
#   skip_service_principal_aad_check = true
# }
