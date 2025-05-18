output "resource_group_name" {
  description = "Output the name of the resource group"
  value       = azurerm_resource_group.rg1.name

}


output "resource_group_location" {
  description = "Output the location of the resource group"
  value       = azurerm_resource_group.rg1.location

}

output "virtual_network_name" {
  description = "Output the name of the virtual network"
  value       = azurerm_virtual_network.myvnet1.name

}