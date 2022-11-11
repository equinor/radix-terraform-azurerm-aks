cluster_name  = "sondre-dev"
whitelist_ips = [] # This will be set in main.tf

#######################################################################################
### AKS
###

aks_node_pool_name     = "nodepool1"
aks_node_pool_vm_size  = "Standard_B4ms"
aks_node_count         = 3
aks_kubernetes_version = "1.23.8"

#######################################################################################
### Zone and cluster settings
###

AZ_LOCATION       = "northeurope"
RADIX_ZONE        = "dev"
RADIX_ENVIRONMENT = "dev"
RADIX_WEB_CONSOLE_ENVIRONMENTS = ["qa", "prod"]

#######################################################################################
### Resource groups
###

AZ_RESOURCE_GROUP_CLUSTERS = "rg_sondre_tf_test" # original "clusters"
AZ_RESOURCE_GROUP_COMMON   = "common"
# AZ_RESOURCE_GROUP_MONITORING="monitoring"
# AZ_RESOURCE_GROUP_LOGS="Logs-Dev"

#######################################################################################
### System users
###

MI_AKSKUBELET = [{
  client_id = "117df4c6-ff5b-4921-9c40-5bea2e1c52d8"
  id        = "/subscriptions/16ede44b-1f74-40a5-b428-46cca9a5741b/resourceGroups/common/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-radix-akskubelet-development-northeurope"
  object_id = "89541870-e10a-403c-8d4c-d80e92dd5eb7"
}]
MI_AKS = [{
  client_id = "1ff97b0f-f824-47d9-a98f-a045b6a759bc"
  id        = "/subscriptions/16ede44b-1f74-40a5-b428-46cca9a5741b/resourceGroups/common/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-radix-aks-development-northeurope",
  object_id = "7112e202-51f7-4fd2-b6a1-b944f14f0be3"
}]

AZ_PRIVATE_DNS_ZONES = [
  "privatelink.database.windows.net",
  "privatelink.blob.core.windows.net",
  "privatelink.table.core.windows.net",
  "privatelink.queue.core.windows.net",
  "privatelink.file.core.windows.net",
  "privatelink.web.core.windows.net",
  "privatelink.dfs.core.windows.net",
  "privatelink.documents.azure.com",
  "privatelink.mongo.cosmos.azure.com",
  "privatelink.cassandra.cosmos.azure.com",
  "privatelink.gremlin.cosmos.azure.com",
  "privatelink.table.cosmos.azure.com",
  "privatelink.postgres.database.azure.com",
  "privatelink.mysql.database.azure.com",
  "privatelink.mariadb.database.azure.com",
  "privatelink.vaultcore.azure.net",
  "private.radix.equinor.com"
]

