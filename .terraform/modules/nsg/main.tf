
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.30" # Ensure a compatible version for NSG features
    }
  }
}

resource "azurerm_network_security_group" "web_nsg" {
  name                = "${var.environment}-web-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags

  # Dynamic block to create ingress security rules for the web tier.
  # This allows for a flexible number of rules to be defined via a variable.
  dynamic "security_rule" {
    for_each = var.web_ingress_rules
    content {
      name                         = security_rule.value.name
      priority                     = security_rule.value.priority
      direction                    = "Inbound"
      access                       = "Allow"
      protocol                     = security_rule.value.protocol
      source_port_range            = security_rule.value.source_port_range
      destination_port_range       = security_rule.value.destination_port_range
      source_address_prefix        = security_rule.value.source_address_prefix
      destination_address_prefix   = security_rule.value.destination_address_prefix
    }
  }
}

# Resource: Application Tier Network Security Group (NSG)
# This NSG is intended for application servers, typically accessed from the web tier.
resource "azurerm_network_security_group" "app_nsg" {
  name                = "${var.environment}-app-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags

  # Dynamic block to create ingress security rules for the application tier.
  dynamic "security_rule" {
    for_each = var.app_ingress_rules
    content {
      name                         = security_rule.value.name
      priority                     = security_rule.value.priority
      direction                    = "Inbound"
      access                       = "Allow"
      protocol                     = security_rule.value.protocol
      source_port_range            = security_rule.value.source_port_range
      destination_port_range       = security_rule.value.destination_port_range
      source_address_prefix        = security_rule.value.source_address_prefix
      destination_address_prefix   = security_rule.value.destination_address_prefix
    }
  }
}

# Resource: Database Tier Network Security Group (NSG)
# This NSG is intended for database servers, typically accessed from the application tier.
resource "azurerm_network_security_group" "db_nsg" {
  name                = "${var.environment}-db-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags

  # Dynamic block to create ingress security rules for the database tier.
  dynamic "security_rule" {
    for_each = var.db_ingress_rules
    content {
      name                         = security_rule.value.name
      priority                     = security_rule.value.priority
      direction                    = "Inbound"
      access                       = "Allow"
      protocol                     = security_rule.value.protocol
      source_port_range            = security_rule.value.source_port_range
      destination_port_range       = security_rule.value.destination_port_range
      source_address_prefix        = security_rule.value.source_address_prefix
      destination_address_prefix   = security_rule.value.destination_address_prefix
    }
  }
}