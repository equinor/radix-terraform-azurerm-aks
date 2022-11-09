variable "cluster_name" {
  description = "Cluster name"
  type        = string
}

variable "location" {
  description = "The location to create the resources in."
  type        = string
}

variable "kubelet_managed_identity" {
  description = "Manage identity to assign to cluster"
  type = list(object({
    client_id    = string
    id           = string
    principal_id = string
  }))
}

variable "managed_identity" {
  description = "Manage identity to assign to cluster"
  type = list(object({
    client_id    = string
    id           = string
    principal_id = string
  }))
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

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the resources."
  type        = map(string)
}

variable "whitelist_ips" {
  description = "value"
  type        = list(string)
}
