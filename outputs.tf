# Resource Group
output "resource_group_name" {
  description = "Name of the resource group"
  value       = module.resource_group.name
}

output "resource_group_location" {
  description = "Location of the resource group"
  value       = module.resource_group.location
}

# Virtual Network
output "vnet_id" {
  description = "ID of the virtual network"
  value       = module.vnet.vnet_id
}

output "vnet_name" {
  description = "Name of the virtual network"
  value       = module.vnet.vnet_name
}

output "subnet_ids" {
  description = "IDs of the subnets"
  value       = module.vnet.subnet_ids
}

# Network Security Groups
output "web_nsg_id" {
  description = "ID of the web tier NSG"
  value       = module.nsg.web_nsg_id
}

output "app_nsg_id" {
  description = "ID of the app tier NSG"
  value       = module.nsg.app_nsg_id
}

output "data_nsg_id" {
  description = "ID of the data tier NSG"
  value       = module.nsg.data_nsg_id
}

# Application Gateway
output "app_gateway_public_ip" {
  description = "Public IP address of the Application Gateway"
  value       = module.app_gateway.public_ip_address
}

# Virtual Machine Scale Set
output "vmss_id" {
  description = "ID of the Virtual Machine Scale Set"
  value       = module.vm.vmss_id
}

# App Service
output "app_service_url" {
  description = "URL of the App Service"
  value       = module.app_service.default_site_hostname
}

# SQL Database
output "sql_server_fqdn" {
  description = "Fully qualified domain name of the SQL server"
  value       = module.sql.server_fqdn
  sensitive   = true
}

# Redis Cache
output "redis_hostname" {
  description = "Hostname of the Redis cache"
  value       = module.redis.hostname
  sensitive   = true
}

# Storage Account
output "storage_account_name" {
  description = "Name of the storage account"
  value       = module.storage.account_name
}

# Cosmos DB
output "cosmosdb_endpoint" {
  description = "Endpoint of the Cosmos DB account"
  value       = module.cosmosdb.endpoint
  sensitive   = true
}
