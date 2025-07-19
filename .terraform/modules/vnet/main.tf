terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.30" # Use a compatible version
    }
  }
}

# Resource: Azure Resource Group

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags = var.tags
}

# Resource: Azure Virtual Network (VNet)
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = [var.vnet_address_space]

  tags = var.tags
}


# Resource: Public Subnet (2)
resource "azurerm_subnet" "public_subnets" {
 
  for_each = var.public_subnets
  name                 = each.value.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.rg.name
  address_prefixes     = [each.value.cidr]
}

# Resource: Private Subnet 1
resource "azurerm_subnet" "private_subnet_1" {
  name                 = var.private_subnet_1_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.rg.name
  address_prefixes     = [var.private_subnet_1_cidr]
}


resource "azurerm_subnet_nat_gateway_association" "nat_associaton" {
  subnet_id      = azurerm_subnet.private_subnet_1.id
  nat_gateway_id = var.nat_gateway_id
}
