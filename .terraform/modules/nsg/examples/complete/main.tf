# Configure the Azure Provider
provider "azurerm" {
  features {}
}

# Explicitly define required_providers for the root configuration
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.30" # Ensure compatibility with the module
    }
  }
}


# Call the terraform-azure-nsg module
module "nsg_example" {
  source              = "../../" # Points to the root of your module
  resource_group_name = "terraform-nsg-example-rg"
  location            = "East US"

  environment = "dev"
  web_ingress_rules = [
    {
      name                       = "AllowHTTP"
      priority                   = 100
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "80"
      source_address_prefix      = "Internet"
      destination_address_prefix = "*"
    },

    {
      name                       = "AllowHTTPS"
      priority                   = 110
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "Internet"
      destination_address_prefix = "*"
    }
  ]

  app_ingress_rules = [
    {
      name                       = "AllowWebToApp"
      priority                   = 100
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "8080"
      source_address_prefix      = "10.0.0.0/22" # Example: VNet CIDR
      destination_address_prefix = "*"
    }
  ]

  db_ingress_rules = [
    {
      name                       = "AllowAppToDB"
      priority                   = 100
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "5432"
      source_address_prefix      = "10.0.0.0/22" # Example: VNet CIDR
      destination_address_prefix = "*"
    }
  ]

  tags = {
    Environment = "Example"
    Project     = "NSGModuleTest"
  }
}
