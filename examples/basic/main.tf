provider "azurerm" {
  features {}
}

locals {
  AZ_RESOURCE_GROUP_VNET_HUB = "cluster-vnet-hub-${var.RADIX_ZONE}"
  CLUSTER_NAME               = var.CLUSTER_NAME
  WHITELIST_IPS              = jsondecode(textdecodebase64("${data.azurerm_key_vault_secret.whitelist_ips.value}", "UTF-8"))
  AKS_NODE_POOLS = [
    {
      name                  = var.AKS_USER_NODE_POOL_NAME
      kubernetes_cluster_id = module.aks.kubernetes_cluster.id
      vm_size               = var.AKS_NODE_POOL_VM_SIZE
      min_count             = var.AKS_USER_NODE_MIN_COUNT
      max_count             = var.AKS_USER_NODE_MAX_COUNT
      mode                  = "User"
      vnet_subnet_id        = module.aks.subnet_cluster.id
    },
    {
      name                  = "nc6sv3"
      kubernetes_cluster_id = module.aks.kubernetes_cluster.id
      vm_size               = "Standard_NC6s_v3"
      min_count             = 0
      max_count             = 1
      mode                  = "User"
      vnet_subnet_id        = module.aks.subnet_cluster.id
      node_labels           = tomap({ sku = "gpu", gpu = "nvidia-v100", gpu-count = "1", radix-node-gpu = "nvidia-v100", radix-node-gpu-count = "1" })
      node_taints           = ["sku=gpu:NoSchedule", "gpu=nvidia-v100:NoSchedule", "gpu-count=1:NoSchedule", "radix-node-gpu=nvidia-v100:NoSchedule", "radix-node-gpu-count=1:NoSchedule"]

    },
    {
      name                  = "nc12sv3"
      kubernetes_cluster_id = module.aks.kubernetes_cluster.id
      vm_size               = "Standard_NC12s_v3"
      min_count             = 0
      max_count             = 1
      mode                  = "User"
      vnet_subnet_id        = module.aks.subnet_cluster.id
      node_labels           = tomap({ sku = "gpu", gpu = "nvidia-v100", gpu-count = "2", radix-node-gpu = "nvidia-v100", radix-node-gpu-count = "2" })
      node_taints           = ["sku=gpu:NoSchedule", "gpu=nvidia-v100:NoSchedule", "gpu-count=2:NoSchedule", "radix-node-gpu=nvidia-v100:NoSchedule", "radix-node-gpu-count=2:NoSchedule"]
    },
    {
      name                  = "nc24sv3"
      kubernetes_cluster_id = module.aks.kubernetes_cluster.id
      vm_size               = "Standard_NC24s_v3"
      min_count             = 0
      max_count             = 1
      mode                  = "User"
      vnet_subnet_id        = module.aks.subnet_cluster.id
      node_labels           = tomap({ sku = "gpu", gpu = "nvidia-v100", gpu-count = "4", radix-node-gpu = "nvidia-v100", radix-node-gpu-count = "4" })
      node_taints           = ["sku=gpu:NoSchedule", "gpu=nvidia-v100:NoSchedule", "gpu-count=4:NoSchedule", "radix-node-gpu=nvidia-v100:NoSchedule", "radix-node-gpu-count=4:NoSchedule"]
    }
  ]
}

data "azurerm_key_vault" "keyvault_env" {
  name                = "radix-vault-${var.RADIX_ENVIRONMENT}"
  resource_group_name = var.AZ_RESOURCE_GROUP_COMMON
}

data "azurerm_key_vault_secret" "whitelist_ips" {
  name         = "kubernetes-api-server-whitelist-ips-${var.RADIX_ENVIRONMENT}"
  key_vault_id = data.azurerm_key_vault.keyvault_env.id
}

data "azurerm_resource_group" "rg_clusters" {
  name = var.AZ_RESOURCE_GROUP_CLUSTERS
}

module "aks" {
  source = "../.."

  CLUSTER_NAME = local.CLUSTER_NAME
  AZ_LOCATION  = var.AZ_LOCATION

  # Resource groups
  AZ_RESOURCE_GROUP_CLUSTERS = data.azurerm_resource_group.rg_clusters.name
  AZ_RESOURCE_GROUP_COMMON   = var.AZ_RESOURCE_GROUP_COMMON
  AZ_RESOURCE_GROUP_VNET_HUB = local.AZ_RESOURCE_GROUP_VNET_HUB

  # network
  # AZ_PRIVATE_DNS_ZONES = var.AZ_PRIVATE_DNS_ZONES
  WHITELIST_IPS = length(local.WHITELIST_IPS.whitelist) != 0 ? [for x in local.WHITELIST_IPS.whitelist : x.ip] : null

  # AKS
  AKS_KUBERNETES_VERSION    = var.AKS_KUBERNETES_VERSION
  AKS_NODE_POOLS            = local.AKS_NODE_POOLS
  AKS_NODE_POOL_VM_SIZE     = var.AKS_NODE_POOL_VM_SIZE
  AKS_SYSTEM_NODE_MAX_COUNT = var.AKS_SYSTEM_NODE_MAX_COUNT
  AKS_SYSTEM_NODE_MIN_COUNT = var.AKS_SYSTEM_NODE_MIN_COUNT
  AKS_SYSTEM_NODE_POOL_NAME = var.AKS_SYSTEM_NODE_POOL_NAME

  # Manage identity
  MI_AKSKUBELET = var.MI_AKSKUBELET
  MI_AKS        = var.MI_AKS

  # Radix
  RADIX_ZONE        = var.RADIX_ZONE
  RADIX_ENVIRONMENT = var.RADIX_ENVIRONMENT
}

resource "azurerm_redis_cache" "redis_cache_web_console" {
  count = length(var.RADIX_WEB_CONSOLE_ENVIRONMENTS)

  name                          = "${local.CLUSTER_NAME}-${var.RADIX_WEB_CONSOLE_ENVIRONMENTS[count.index]}"
  resource_group_name           = data.azurerm_resource_group.rg_clusters.name
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
  name                  = "${local.CLUSTER_NAME}-link"
  resource_group_name   = local.AZ_RESOURCE_GROUP_VNET_HUB
  private_dns_zone_name = var.AZ_PRIVATE_DNS_ZONES[count.index]
  virtual_network_id    = module.aks.vnet_cluster.id
  registration_enabled  = false
}
