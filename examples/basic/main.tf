provider "azurerm" {
  features {}
}

data "azurerm_key_vault" "this" {
  name                = "radix-vault-dev"
  resource_group_name = var.AZ_RESOURCE_GROUP_COMMON
}

data "azurerm_key_vault_secret" "this" {
  name         = "kubernetes-api-server-whitelist-ips-dev"
  key_vault_id = data.azurerm_key_vault.this.id
}

locals {
  whitelist_ips = jsondecode(textdecodebase64("${data.azurerm_key_vault_secret.this.value}", "UTF-8"))
}

resource "azurerm_resource_group" "this" {
  name     = var.AZ_RESOURCE_GROUP_CLUSTERS
  location = var.AZ_LOCATION
}

module "aks" {
  # source = "github.com/equinor/radix-terraform-azurerm-aks"
  source = "../.."

  cluster_name               = var.cluster_name
  AZ_RESOURCE_GROUP_CLUSTERS = azurerm_resource_group.this.name
  AZ_RESOURCE_GROUP_COMMON   = var.AZ_RESOURCE_GROUP_COMMON
  AZ_LOCATION                = var.AZ_LOCATION
  whitelist_ips              = length(local.whitelist_ips.whitelist) != 0 ? [for x in local.whitelist_ips.whitelist : x.ip] : null

  node_pool_name    = var.node_pool_name
  node_pool_vm_size = var.node_pool_vm_size
  node_count        = var.node_count

  # Manage identity
  MI_AKSKUBELET = var.MI_AKSKUBELET
  MI_AKS        = var.MI_AKS

  # Radix (optional)
  RADIX_ZONE        = var.RADIX_ZONE
  RADIX_ENVIRONMENT = var.RADIX_ENVIRONMENT
}
