AZ_LOCATION       = "northeurope"
cluster_name      = "sondre-dev"
node_pool_name    = "nodepool1"
node_pool_vm_size = "Standard_B4ms"
node_count        = 3
whitelist_ips     = []

#######################################################################################
### Zone and cluster settings
###

RADIX_ZONE        = "dev"
RADIX_ENVIRONMENT = "dev"

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

