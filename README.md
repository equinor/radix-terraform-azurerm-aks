# Azure Kubernetes Terraform module

Terraform module which creates Azure Kubernetes resources.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 3.0.0 |
| <a name="provider_external"></a> [external](#provider\_external) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_kubernetes_cluster.kubernetes_cluster](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster) | resource |
| [azurerm_kubernetes_cluster_node_pool.nodepools](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster_node_pool) | resource |
| [azurerm_network_security_group.nsg_cluster](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_public_ip.pip_ingress](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_subnet.subnet_cluster](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_virtual_network.vnet_cluster](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [azurerm_virtual_network_peering.cluster_to_hub](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering) | resource |
| [azurerm_virtual_network_peering.hub_to_cluster](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering) | resource |
| [random_id.four_byte](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [azurerm_virtual_network.hub](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network) | data source |
| [external_external.getAddressSpaceForVNET](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |
| [external_external.getPublicOutboundIps](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_AKS_KUBERNETES_VERSION"></a> [AKS\_KUBERNETES\_VERSION](#input\_AKS\_KUBERNETES\_VERSION) | kubernetes version | `string` | n/a | yes |
| <a name="input_AKS_NODE_POOLS"></a> [AKS\_NODE\_POOLS](#input\_AKS\_NODE\_POOLS) | List of different nodepools configurations | <pre>list(object({<br>    name                  = string<br>    kubernetes_cluster_id = string<br>    vm_size               = string<br>    min_count             = number<br>    max_count             = number<br>    mode                  = string<br>    vnet_subnet_id        = string<br>    node_labels           = optional(map(any))<br>    node_taints           = optional(list(string))<br>  }))</pre> | n/a | yes |
| <a name="input_AKS_NODE_POOL_VM_SIZE"></a> [AKS\_NODE\_POOL\_VM\_SIZE](#input\_AKS\_NODE\_POOL\_VM\_SIZE) | The SKU which should be used for the Virtual Machines used in this Node Pool | `string` | n/a | yes |
| <a name="input_AKS_SYSTEM_NODE_MAX_COUNT"></a> [AKS\_SYSTEM\_NODE\_MAX\_COUNT](#input\_AKS\_SYSTEM\_NODE\_MAX\_COUNT) | The maximum number of nodes which should exist in this Node Pool | `number` | n/a | yes |
| <a name="input_AKS_SYSTEM_NODE_MIN_COUNT"></a> [AKS\_SYSTEM\_NODE\_MIN\_COUNT](#input\_AKS\_SYSTEM\_NODE\_MIN\_COUNT) | The minimum number of nodes which should exist in this Node Pool | `number` | n/a | yes |
| <a name="input_AKS_SYSTEM_NODE_POOL_NAME"></a> [AKS\_SYSTEM\_NODE\_POOL\_NAME](#input\_AKS\_SYSTEM\_NODE\_POOL\_NAME) | The name of the Node Pool which should be created within the Kubernetes Cluster | `string` | n/a | yes |
| <a name="input_AZ_LOCATION"></a> [AZ\_LOCATION](#input\_AZ\_LOCATION) | The location to create the resources in. | `string` | n/a | yes |
| <a name="input_AZ_RESOURCE_GROUP_CLUSTERS"></a> [AZ\_RESOURCE\_GROUP\_CLUSTERS](#input\_AZ\_RESOURCE\_GROUP\_CLUSTERS) | Resource group name for clusters | `string` | n/a | yes |
| <a name="input_AZ_RESOURCE_GROUP_COMMON"></a> [AZ\_RESOURCE\_GROUP\_COMMON](#input\_AZ\_RESOURCE\_GROUP\_COMMON) | Resource group name for common | `string` | n/a | yes |
| <a name="input_AZ_RESOURCE_GROUP_VNET_HUB"></a> [AZ\_RESOURCE\_GROUP\_VNET\_HUB](#input\_AZ\_RESOURCE\_GROUP\_VNET\_HUB) | Resource group name for vnet hub | `string` | n/a | yes |
| <a name="input_AZ_SUBSCRIPTION_ID"></a> [AZ\_SUBSCRIPTION\_ID](#input\_AZ\_SUBSCRIPTION\_ID) | Azure subscription id | `string` | n/a | yes |
| <a name="input_CLUSTER_NAME"></a> [CLUSTER\_NAME](#input\_CLUSTER\_NAME) | The name of the Managed Kubernetes Cluster to create | `string` | n/a | yes |
| <a name="input_CLUSTER_TYPE"></a> [CLUSTER\_TYPE](#input\_CLUSTER\_TYPE) | cluster type | `string` | n/a | yes |
| <a name="input_MIGRATION_STRATEGY"></a> [MIGRATION\_STRATEGY](#input\_MIGRATION\_STRATEGY) | The migration strategy to use | `string` | n/a | yes |
| <a name="input_MI_AKS"></a> [MI\_AKS](#input\_MI\_AKS) | Manage identity to assign to cluster | <pre>list(object({<br>    client_id = string<br>    id        = string<br>    object_id = string<br>  }))</pre> | n/a | yes |
| <a name="input_MI_AKSKUBELET"></a> [MI\_AKSKUBELET](#input\_MI\_AKSKUBELET) | Manage identity to assign to cluster | <pre>list(object({<br>    client_id = string<br>    id        = string<br>    object_id = string<br>  }))</pre> | n/a | yes |
| <a name="input_RADIX_ENVIRONMENT"></a> [RADIX\_ENVIRONMENT](#input\_RADIX\_ENVIRONMENT) | Radix environment | `string` | n/a | yes |
| <a name="input_RADIX_ZONE"></a> [RADIX\_ZONE](#input\_RADIX\_ZONE) | Radix zone | `string` | n/a | yes |
| <a name="input_WHITELIST_IPS"></a> [WHITELIST\_IPS](#input\_WHITELIST\_IPS) | value | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_kubernetes_cluster"></a> [kubernetes\_cluster](#output\_kubernetes\_cluster) | kubernetes cluster resource |
| <a name="output_subnet_cluster"></a> [subnet\_cluster](#output\_subnet\_cluster) | subnet resource |
| <a name="output_vnet_cluster"></a> [vnet\_cluster](#output\_vnet\_cluster) | VNET resource |
<!-- END_TF_DOCS -->