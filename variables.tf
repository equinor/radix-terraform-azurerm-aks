variable "AZ_LOCATION" {
  description = "The location to create the resources in."
  type        = string
}

variable "AZ_RESOURCE_GROUP_CLUSTERS" {
  description = "Resource group name for clusters"
  type        = string
}

variable "AZ_RESOURCE_GROUP_COMMON" {
  description = "Resource group name for common"
  type        = string
}

variable "AZ_RESOURCE_GROUP_VNET_HUB" {
  description = "Resource group name for vnet hub"
  type        = string
}
variable "CLUSTER_NAME" {
  description = "Cluster name"
  type        = string
}

variable "AKS_NODE_POOL_NAME" {
  description = "Node pool name"
  type        = string
}

variable "AKS_NODE_POOL_VM_SIZE" {
  description = "VM type"
  type        = string
}

variable "AKS_NODE_COUNT" {
  description = "Number of nodes"
  type        = number
}

variable "AKS_KUBERNETES_VERSION" {
  description = "kubernetes version"
  type        = string
}

variable "WHITELIST_IPS" {
  description = "value"
  type        = list(string)
}

variable "MI_AKSKUBELET" {
  description = "Manage identity to assign to cluster"
  type = list(object({
    client_id = string
    id        = string
    object_id = string
  }))
}

variable "MI_AKS" {
  description = "Manage identity to assign to cluster"
  type = list(object({
    client_id = string
    id        = string
    object_id = string
  }))
}

variable "RADIX_ZONE" {
  description = "Radix zone"
  type        = string
}

variable "RADIX_ENVIRONMENT" {
  description = "Radix environment"
  type        = string
}
