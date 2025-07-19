# Output: web_nsg_id
# The ID of the created web tier Network Security Group.
output "web_nsg_id" {
  description = "The ID of the web tier Network Security Group."
  value       = azurerm_network_security_group.web_nsg.id
}

# Output: app_nsg_id
# The ID of the created application tier Network Security Group.
output "app_nsg_id" {
  description = "The ID of the application tier Network Security Group."
  value       = azurerm_network_security_group.app_nsg.id
}

# Output: db_nsg_id
# The ID of the created database tier Network Security Group.
output "db_nsg_id" {
  description = "The ID of the database tier Network Security Group."
  value       = azurerm_network_security_group.db_nsg.id
}

# Output: web_nsg_name
# The name of the created web tier Network Security Group.
output "web_nsg_name" {
  description = "The name of the web tier Network Security Group."
  value       = azurerm_network_security_group.web_nsg.name
}

# Output: app_nsg_name
# The name of the created application tier Network Security Group.
output "app_nsg_name" {
  description = "The name of the application tier Network Security Group."
  value       = azurerm_network_security_group.app_nsg.name
}

# Output: db_nsg_name
# The name of the created database tier Network Security Group.
output "db_nsg_name" {
  description = "The name of the database tier Network Security Group."
  value       = azurerm_network_security_group.db_nsg.name
}