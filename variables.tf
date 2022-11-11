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

variable "AZ_PRIVATE_DNS_ZONES" {
  description = "Private DNS zones to link with VNET"
  type        = list(string)
}

variable "cluster_name" {
  description = "Cluster name"
  type        = string
}

variable "aks_node_pool_name" {
  description = "Node pool name"
  type        = string
}

variable "aks_node_pool_vm_size" {
  description = "VM type"
  type        = string
}

variable "aks_node_count" {
  description = "Number of nodes"
  type        = number
}

variable "aks_kubernetes_version" {
  description = "kubernetes version"
  type        = string
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

variable "RADIX_WEB_CONSOLE_ENVIRONMENTS" {
  description = "A list of environments for web console"
  type        = list(string)
}
