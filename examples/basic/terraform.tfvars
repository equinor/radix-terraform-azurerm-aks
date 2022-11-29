cluster_name  = "radix-azurerm-aks-example"
# whitelist_ips = [] # This will be set in main.tf

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
# RADIX_ZONE        = ""
# RADIX_ENVIRONMENT = ""
# RADIX_WEB_CONSOLE_ENVIRONMENTS = []

#######################################################################################
### Resource groups
###

AZ_RESOURCE_GROUP_CLUSTERS = "radix-azurerm-aks-example" # original "clusters"
# AZ_RESOURCE_GROUP_COMMON   = ""

#######################################################################################
### System users
###

# MI_AKSKUBELET = [{
#   client_id = ""
#   id        = ""
#   object_id = ""
# }]
# MI_AKS = [{
#   client_id = ""
#   id        = "",
#   object_id = ""
# }]

# AZ_PRIVATE_DNS_ZONES = []

