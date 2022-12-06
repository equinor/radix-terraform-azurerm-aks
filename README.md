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

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_random_id.four_byte](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/random_id) | resource |
| [azurerm_kubernetes_cluster.kubernetes_cluster](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster) | resource |
| [azurerm_virtual_network.vnet_cluster](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [azurerm_virtual_network_peering.cluster_to_hub](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering) | resource |
| [azurerm_virtual_network_peering.hub_to_cluster](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering) | resource |
| [azurerm_subnet.subnet_cluster](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_network_security_group.nsg_cluster](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_public_ip.pip_ingress](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_private_dns_zone_virtual_network_link.cluster_link](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_AZ_LOCATION"></a> [AZ_LOCATION](#input\_AZ_LOCATION) | The location to create the resources in. | `string` | n/a | yes |
| <a name="input_AZ_RESOURCE_GROUP_CLUSTERS"></a> [AZ_RESOURCE_GROUP_CLUSTERS](#input\_AZ_RESOURCE_GROUP_CLUSTERS) | Resource group name for clusters | `string` | n/a | yes |
| <a name="input_AZ_RESOURCE_GROUP_COMMON"></a> [AZ_RESOURCE_GROUP_COMMON](#input\_AZ_RESOURCE_GROUP_COMMON) | Resource group name for common | `string` | n/a | yes |
| <a name="input_AZ_RESOURCE_GROUP_VNET_HUB"></a> [AZ_RESOURCE_GROUP_VNET_HUB](#input\_AZ_RESOURCE_GROUP_VNET_HUB) | Resource group name for vnet hub | `string` | n/a | yes |
| <a name="input_CLUSTER_NAME"></a> [CLUSTER_NAME](#input\_CLUSTER_NAME) | Cluster name | `string` | n/a | yes |
| <a name="input_AKS_NODE_POOL_NAME"></a> [AKS_NODE_POOL_NAME](#input\_AKS_NODE_POOL_NAME) | Node pool name | `string` | n/a | yes |
| <a name="input_AKS_NODE_POOL_VM_SIZE"></a> [AKS_NODE_POOL_VM_SIZE](#input\_AKS_NODE_POOL_VM_SIZE) | VM type | `string` | n/a | yes |
| <a name="input_AKS_NODE_COUNT"></a> [AKS_NODE_COUNT](#input\_AKS_NODE_COUNT) | Number of nodes | `number` | n/a | yes |
| <a name="input_AKS_KUBERNETES_VERSION"></a> [AKS_KUBERNETES_VERSION](#input\_AKS_KUBERNETES_VERSION) | kubernetes version | `string` | n/a | yes |
| <a name="input_WHITELIST_IPS"></a> [WHITELIST_IPS](#input\_WHITELIST_IPS) | value | `list(string)` | n/a | yes |
| <a name="input_MI_AKSKUBELET"></a> [MI_AKSKUBELET](#input\_MI_AKSKUBELET) | Manage identity to assign to cluster | `list(object())` | n/a | yes |
| <a name="input_MI_AKS"></a> [MI_AKS](#input\_MI_AKS) | Manage identity to assign to cluster | `list(object())` | n/a | yes |
| <a name="input_RADIX_ZONE"></a> [RADIX_ZONE](#input\_RADIX_ZONE) | Radix zone | `string` | n/a | yes |
| <a name="input_RADIX_ENVIRONMENT"></a> [RADIX_ENVIRONMENT](#input\_RADIX_ENVIRONMENT) | Radix environment | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vnet_cluster"></a> [vnet_cluster](#output\_vnet_cluster) | VNET resource |
<!-- END_TF_DOCS -->