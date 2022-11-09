provider "azurerm" {
  features {}
}

data "azurerm_key_vault" "this" {
  name                = "radix-vault-dev"
  resource_group_name = "common"
}

data "azurerm_key_vault_secret" "this" {
  name         = "kubernetes-api-server-whitelist-ips-dev"
  key_vault_id = data.azurerm_key_vault.this.id
}

locals {
  tags = {
    environment = "test"
  }
  whitelist_ips = jsondecode(textdecodebase64("${data.azurerm_key_vault_secret.this.value}", "UTF-8"))
}

resource "random_id" "this" {
  byte_length = 4
}

resource "azurerm_resource_group" "this" {
  name     = "${var.resource_group_name}-${random_id.this.hex}"
  location = var.location

  tags = local.tags
}

module "aks" {
  # source = "github.com/equinor/radix-terraform-azurerm-aks"
  source = "../.."

  cluster_name        = var.cluster_name
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  whitelist_ips       = length(local.whitelist_ips.whitelist) != 0 ? [for x in local.whitelist_ips.whitelist : x.ip] : null

  node_pool_name    = var.node_pool_name
  node_pool_vm_size = var.node_pool_vm_size
  node_count        = var.node_count

  # Manage identity
  kubelet_managed_identity = var.kubelet_managed_identity
  managed_identity = var.managed_identity

  tags = local.tags
}
