# outputs.tf
output "sql_server_name" {
  description = "The name of the SQL server"
  value       = azurerm_mssql_server.sql_server.name
}

output "sql_server_fqdn" {
  description = "Fully qualified domain name of the SQL server"
  value       = azurerm_mssql_server.sql_server.fully_qualified_domain_name
}

output "sql_database_name" {
  description = "The name of the SQL database"
  value       = azurerm_mssql_database.sql_db.name
}
