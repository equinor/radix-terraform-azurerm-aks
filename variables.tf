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

variable "AZ_SUBSCRIPTION_ID" {
  description = "Azure subscription id"
  type        = string
}

variable "AZ_RESOURCE_GROUP_VNET_HUB" {
  description = "Resource group name for vnet hub"
  type        = string
}

variable "AKS_SYSTEM_NODE_POOL_NAME" {
  description = "The name of the Node Pool which should be created within the Kubernetes Cluster"
  type        = string
}

variable "AKS_NODE_POOLS" {
  description = "List of different nodepools configurations"
  type = list(object({
    name                  = string
    kubernetes_cluster_id = string
    vm_size               = string
    min_count             = number
    max_count             = number
    mode                  = string
    vnet_subnet_id        = string
    node_labels           = optional(map(any))
    node_taints           = optional(list(string))
  }))
}


variable "AKS_NODE_POOL_VM_SIZE" {
  description = "The SKU which should be used for the Virtual Machines used in this Node Pool"
  type        = string
}

variable "AKS_SYSTEM_NODE_MIN_COUNT" {
  description = "The minimum number of nodes which should exist in this Node Pool"
  type        = number
}

variable "AKS_SYSTEM_NODE_MAX_COUNT" {
  description = "The maximum number of nodes which should exist in this Node Pool"
  type        = number
}

variable "AKS_KUBERNETES_VERSION" {
  description = "kubernetes version"
  type        = string
}

variable "CLUSTER_NAME" {
  description = "The name of the Managed Kubernetes Cluster to create"
  type        = string
}

variable "CLUSTER_TYPE" {
  description = "cluster type"
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

variable "MIGRATION_STRATEGY" {
  description = "The migration strategy to use"
  type        = string
}

variable "RADIX_ZONE" {
  description = "Radix zone"
  type        = string
}

variable "RADIX_ENVIRONMENT" {
  description = "Radix environment"
  type        = string
}

variable "TAGS" {
  description = "tags"
  type        = map(string)
  default     = {}
}
