variable "AZ_LOCATION" {
  description = "The location to create the resources in."
  type        = string
  default     = "northeurope"
}

variable "AZ_RESOURCE_GROUP_CLUSTERS" {
  description = "Resource group name for clusters"
  type        = string
  default     = "rg_sondre_tf_test"
}

variable "AZ_RESOURCE_GROUP_COMMON" {
  description = "Resource group name for common"
  type        = string
}

variable "cluster_name" {
  description = "Cluster name"
  type        = string
  default     = "sondre-dev"
}

variable "node_pool_name" {
  description = "Node pool name"
  type        = string
  default     = "nodepool1"
}

variable "node_pool_vm_size" {
  description = "VM type"
  type        = string
  default     = "Standard_B4ms"
}

variable "node_count" {
  description = "Number of nodes"
  type        = number
  default     = 3
}

variable "whitelist_ips" {
  description = "List ipadresses that should be able to access the cluster"
  type        = list(string)
  default     = []
}

variable "MI_AKSKUBELET" {
  description = "Manage identity to assign to cluster"
  type = list(object({
    client_id = string
    id        = string
    object_id = string
  }))
  default = [{
    client_id = "117df4c6-ff5b-4921-9c40-5bea2e1c52d8"
    id        = "/subscriptions/16ede44b-1f74-40a5-b428-46cca9a5741b/resourceGroups/common/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-radix-akskubelet-development-northeurope"
    object_id = "89541870-e10a-403c-8d4c-d80e92dd5eb7"
  }]
}

variable "MI_AKS" {
  description = "Manage identity to assign to cluster"
  type = list(object({
    client_id = string
    id        = string
    object_id = string
  }))
  default = [{
    client_id = "1ff97b0f-f824-47d9-a98f-a045b6a759bc"
    id        = "/subscriptions/16ede44b-1f74-40a5-b428-46cca9a5741b/resourceGroups/common/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-radix-aks-development-northeurope",
    object_id = "7112e202-51f7-4fd2-b6a1-b944f14f0be3"
  }]
}

variable "RADIX_ZONE" {
  description = "Radix zone"
  type        = string
}

variable "RADIX_ENVIRONMENT" {
  description = "Radix environment"
  type        = string
}
