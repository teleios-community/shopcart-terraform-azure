terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-terraform-sql"
  location = "eastus"
}

module "sql" {
  source = "../../"

  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sql_server_name     = "sqlserver${random_integer.suffix.result}"
  sql_admin_username  = "sqladminuser"
  sql_admin_password  = "StrongP@ssw0rd123!"
  database_name       = "sampledb"
  sku_name            = "S0"
}

resource "random_integer" "suffix" {
  min = 1000
  max = 9999
}