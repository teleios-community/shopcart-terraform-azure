# variables.tf
variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure location (e.g., eastus)"
  type        = string
}

variable "sql_server_name" {
  description = "Name of the Azure SQL Server"
  type        = string
}

variable "sql_admin_username" {
  description = "Administrator username for the SQL server"
  type        = string
}

variable "sql_admin_password" {
  description = "Administrator password for the SQL server"
  type        = string
  sensitive   = true
}

variable "database_name" {
  description = "Name of the SQL database"
  type        = string
}

variable "sku_name" {
  description = "The SKU for the SQL database (e.g., Basic, S0, P1)"
  type        = string
  default     = "S0"
}
