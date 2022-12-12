output "vnet_cluster" {
  description = "VNET resource"
  value = azurerm_virtual_network.vnet_cluster
}

output "subnet_cluster" {
  description = "subnet resource"
  value = azurerm_subnet.subnet_cluster
}

output "kubernetes_cluster" {
  description = "kubernetes cluster resource"
  value = azurerm_kubernetes_cluster.kubernetes_cluster
}
