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

variable "cluster_name" {
  description = "Cluster name"
  type        = string
}

variable "node_pool_name" {
  description = "Node pool name"
  type        = string
}

variable "node_pool_vm_size" {
  description = "VM type"
  type        = string
}

variable "node_count" {
  description = "Number of nodes"
  type        = number
}

variable "whitelist_ips" {
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
