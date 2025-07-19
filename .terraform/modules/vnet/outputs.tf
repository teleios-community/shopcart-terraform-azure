output "vnet_id" {
  description = "The ID of the Virtual Network."
  value       = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  description = "The name of the Virtual Network."
  value       = azurerm_virtual_network.vnet.name
}

output "public_subnet_ids" {
  description = "A map of IDs for the created public subnets."
  value       = { for k, v in azurerm_subnet.public_subnets : k => v.id }
}

output "public_subnet_names" {
  description = "A map of names for the created public subnets."
  value       = { for k, v in azurerm_subnet.public_subnets : k => v.name }
}

output "private_subnet_1_id" {
  description = "The ID of the private subnet."
  value       = azurerm_subnet.private_subnet_1.id
}

output "private_subnet_ids" {
  description = "A list of IDs for all private subnets."
  value       = [azurerm_subnet.private_subnet_1.id]
}

output "resource_group_name" {
  description = "The name of the resource group used by the module."
  value       = azurerm_resource_group.rg.name
}