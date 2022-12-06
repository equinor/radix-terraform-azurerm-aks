provider "azurerm" {
  features {}
}

locals {
  WHITELIST_IPS = jsondecode(textdecodebase64("${data.azurerm_key_vault_secret.WHITELIST_IPS.value}", "UTF-8"))
  AZ_RESOURCE_GROUP_VNET_HUB = "cluster-vnet-hub-${var.RADIX_ZONE}"
}

data "azurerm_key_vault" "keyvault_env" {
  name                = "radix-vault-dev"
  resource_group_name = var.AZ_RESOURCE_GROUP_COMMON
}

data "azurerm_key_vault_secret" "WHITELIST_IPS" {
  name         = "kubernetes-api-server-whitelist-ips-dev"
  key_vault_id = data.azurerm_key_vault.keyvault_env.id
}

resource "azurerm_resource_group" "rg_clusters" {
  name     = var.AZ_RESOURCE_GROUP_CLUSTERS
  location = var.AZ_LOCATION
}

module "aks" {
  # source = "github.com/equinor/radix-terraform-azurerm-aks"
  source = "../.."

  CLUSTER_NAME = var.CLUSTER_NAME
  AZ_LOCATION  = var.AZ_LOCATION

  # Resource groups
  AZ_RESOURCE_GROUP_CLUSTERS = azurerm_resource_group.rg_clusters.name
  AZ_RESOURCE_GROUP_COMMON   = var.AZ_RESOURCE_GROUP_COMMON
  AZ_RESOURCE_GROUP_VNET_HUB = local.AZ_RESOURCE_GROUP_VNET_HUB

  # network
  # AZ_PRIVATE_DNS_ZONES = var.AZ_PRIVATE_DNS_ZONES
  WHITELIST_IPS        = length(local.WHITELIST_IPS.whitelist) != 0 ? [for x in local.WHITELIST_IPS.whitelist : x.ip] : null

  # AKS
  AKS_NODE_POOL_NAME     = var.AKS_NODE_POOL_NAME
  AKS_NODE_POOL_VM_SIZE  = var.AKS_NODE_POOL_VM_SIZE
  AKS_NODE_COUNT         = var.AKS_NODE_COUNT
  AKS_KUBERNETES_VERSION = var.AKS_KUBERNETES_VERSION

  # Manage identity
  MI_AKSKUBELET = var.MI_AKSKUBELET
  MI_AKS        = var.MI_AKS

  # Radix
  RADIX_ZONE                     = var.RADIX_ZONE
  RADIX_ENVIRONMENT              = var.RADIX_ENVIRONMENT
}

resource "azurerm_redis_cache" "redis_cache_web_console" {
  count = length(var.RADIX_WEB_CONSOLE_ENVIRONMENTS)

  name                          = "${var.CLUSTER_NAME}-${var.RADIX_WEB_CONSOLE_ENVIRONMENTS[count.index]}"
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

resource "azurerm_private_dns_zone_virtual_network_link" "cluster_link" {
  count                 = length(var.AZ_PRIVATE_DNS_ZONES)
  name                  = "${var.CLUSTER_NAME}-link"
  resource_group_name   = local.AZ_RESOURCE_GROUP_VNET_HUB
  private_dns_zone_name = var.AZ_PRIVATE_DNS_ZONES[count.index]
  virtual_network_id    = module.aks.vnet_cluster.id
  registration_enabled  = false
}
