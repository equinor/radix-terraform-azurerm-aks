
data "azurerm_container_registry" "this" {
  name                = "radixdev"
  resource_group_name = "common"
}

data "azurerm_virtual_network" "hub" {
  name                = "vnet-hub"
  resource_group_name = "cluster-vnet-hub-dev"
}

resource "random_id" "this" {
  byte_length = 4
}

locals {
  AZ_PRIVATE_DNS_ZONES = ["privatelink.database.windows.net",
    "privatelink.blob.core.windows.net",
    "privatelink.table.core.windows.net",
    "privatelink.queue.core.windows.net",
    "privatelink.file.core.windows.net",
    "privatelink.web.core.windows.net",
    "privatelink.dfs.core.windows.net",
    "privatelink.documents.azure.com",
    "privatelink.mongo.cosmos.azure.com",
    "privatelink.cassandra.cosmos.azure.com",
    "privatelink.gremlin.cosmos.azure.com",
    "privatelink.table.cosmos.azure.com",
    "privatelink.postgres.database.azure.com",
    "privatelink.mysql.database.azure.com",
    "privatelink.mariadb.database.azure.com",
    "privatelink.vaultcore.azure.net",
  "private.radix.equinor.com"]
}

resource "azurerm_kubernetes_cluster" "this" {
  name                            = var.cluster_name
  location                        = var.location
  resource_group_name             = var.resource_group_name
  dns_prefix                      = "${var.cluster_name}-${random_id.this.hex}"
  kubernetes_version              = "1.23.8"
  local_account_disabled          = true
  sku_tier                        = "Paid"
  api_server_authorized_ip_ranges = length(var.whitelist_ips) != 0 ? var.whitelist_ips : null

  tags = var.tags

  azure_active_directory_role_based_access_control {
    managed                = true
    admin_group_object_ids = ["a5dfa635-dc00-4a28-9ad9-9e7f1e56919d"]
  }

  default_node_pool {
    name                = var.node_pool_name
    vm_size             = var.node_pool_vm_size
    node_count          = var.node_count
    enable_auto_scaling = true
    min_count           = 2
    max_count           = 5
    max_pods            = 110
    os_disk_size_gb     = 128
    vnet_subnet_id      = azurerm_subnet.this.id
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [var.managed_identity[0].id]
  }

  network_profile {
    network_plugin     = "azure"
    network_policy     = "calico"
    docker_bridge_cidr = "172.17.0.1/16"
    dns_service_ip     = "10.2.0.10"
    service_cidr = "10.2.0.0/18" 
  }

  key_vault_secrets_provider {
    secret_rotation_enabled = true
  }

  kubelet_identity {
    client_id                 = var.managed_identity[0].client_id
    object_id                 = var.managed_identity[0].id
    user_assigned_identity_id = var.managed_identity[0].id
  }
}

resource "azurerm_role_assignment" "this" {
  principal_id                     = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = data.azurerm_container_registry.this.id
  skip_service_principal_aad_check = true
}


# resource "azurerm_container_registry" "this" {
#   name                          = "radixdev"
#   resource_group_name           = "common"
#   location                      = "northeurope"
#   sku                           = "Premium"
#   public_network_access_enabled = true
#   admin_enabled                 = true

#   network_rule_set = [{
#     default_action = "Deny"
#     ip_rule = [
#       {
#         "action" : "Allow",
#         "ip_range" : "104.45.84.0/30"
#       },
#       {
#         "action" : "Allow",
#         "ip_range" : "104.45.86.104/30"
#       },
#       {
#         "action" : "Allow",
#         "ip_range" : "143.97.110.1/32"
#       },
#       {
#         "action" : "Allow",
#         "ip_range" : "143.97.2.35/32"
#       },
#       {
#         "action" : "Allow",
#         "ip_range" : "20.107.130.185/32"
#       },
#       {
#         "action" : "Allow",
#         "ip_range" : "20.67.211.10/32"
#       },
#       {
#         "action" : "Allow",
#         "ip_range" : "51.104.179.78/32"
#       },
#       {
#         "action" : "Allow",
#         "ip_range" : "85.19.71.228/30"
#       },
#       {
#         "action" : "Allow",
#         "ip_range" : "92.221.23.247/32"
#       }
#     ]
#     virtual_network = []
#   }]
# }

resource "azurerm_virtual_network" "this" {
  name                = "vnet-${var.cluster_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = ["10.0.0.0/16"] # get address_space from vnet-hub

  # subnet {
  #   name           = "subnet-${var.cluster_name}"
  #   security_group = azurerm_network_security_group.this.name
  #   address_prefix = azurerm_subnet.this.address_prefixes
  # }
}

resource "azurerm_virtual_network_peering" "this" {
  name                         = "hub-to-${var.cluster_name}"
  resource_group_name          = "cluster-vnet-hub-dev"
  virtual_network_name         = data.azurerm_virtual_network.hub.name
  remote_virtual_network_id    = azurerm_virtual_network.this.id
  allow_virtual_network_access = true
}

resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  count                 = length(local.AZ_PRIVATE_DNS_ZONES)
  name                  = "${var.cluster_name}-link"
  resource_group_name   = "cluster-vnet-hub-dev"
  private_dns_zone_name = local.AZ_PRIVATE_DNS_ZONES[count.index]
  virtual_network_id    = azurerm_virtual_network.this.id
  registration_enabled  = false
}

resource "azurerm_subnet" "this" {
  name                 = "subnet-${var.cluster_name}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.0.0.0/18"] # get address_space from vnet-hub
}

resource "azurerm_network_security_group" "this" {
  name                = "nsg-${var.cluster_name}"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "nsg-${var.cluster_name}"
    priority                   = "100"
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    destination_port_range     = "80,443"
    destination_address_prefix = ""
    source_port_range          = "*"
    source_address_prefix      = "*"
  }
}
