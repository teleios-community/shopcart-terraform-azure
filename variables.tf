# Environment Configuration
variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "East US"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "shopcart"
}

# Virtual Network Configuration
variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_config" {
  description = "Subnet configuration"
  type = map(object({
    address_prefixes = list(string)
    service_endpoints = optional(list(string), [])
  }))
  default = {
    web = {
      address_prefixes = ["10.0.1.0/24"]
      service_endpoints = ["Microsoft.Web"]
    }
    app = {
      address_prefixes = ["10.0.2.0/24"]
      service_endpoints = ["Microsoft.Sql"]
    }
    data = {
      address_prefixes = ["10.0.3.0/24"]
      service_endpoints = ["Microsoft.Sql", "Microsoft.Storage"]
    }
  }
}

# Virtual Machine Scale Set Configuration
variable "vmss_sku" {
  description = "SKU for Virtual Machine Scale Set instances"
  type        = string
  default     = "Standard_B2s"
}

variable "vmss_capacity" {
  description = "Initial capacity for VMSS"
  type = object({
    min     = number
    max     = number
    default = number
  })
  default = {
    min     = 1
    max     = 10
    default = 2
  }
}

# App Service Configuration
variable "app_service_plan_sku" {
  description = "SKU for App Service Plan"
  type = object({
    tier = string
    size = string
  })
  default = {
    tier = "Standard"
    size = "S1"
  }
}

# Azure SQL Configuration
variable "sql_server_config" {
  description = "Azure SQL Server configuration"
  type = object({
    administrator_login = string
    sku_name           = string
    max_size_gb        = number
  })
  default = {
    administrator_login = "sqladmin"
    sku_name           = "S0"
    max_size_gb        = 250
  }
}

# Redis Configuration
variable "redis_config" {
  description = "Azure Cache for Redis configuration"
  type = object({
    capacity = number
    family   = string
    sku_name = string
  })
  default = {
    capacity = 1
    family   = "C"
    sku_name = "Standard"
  }
}

# Storage Account Configuration
variable "storage_account_tier" {
  description = "Storage account performance tier"
  type        = string
  default     = "Standard"
}

variable "storage_replication_type" {
  description = "Storage account replication type"
  type        = string
  default     = "LRS"
}

# Cosmos DB Configuration
variable "cosmosdb_config" {
  description = "Cosmos DB configuration"
  type = object({
    offer_type      = string
    consistency_level = string
    throughput      = number
  })
  default = {
    offer_type      = "Standard"
    consistency_level = "Session"
    throughput      = 400
  }
}

# Network Security Group Rules
variable "web_security_rules" {
  description = "Security rules for web tier"
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
  default = [
    {
      name                       = "Allow-HTTP"
      priority                   = 1001
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "80"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    {
      name                       = "Allow-HTTPS"
      priority                   = 1002
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  ]
}

# Sensitive Variables (will be set in Terraform Cloud)
variable "sql_administrator_password" {
  description = "Password for SQL Server administrator"
  type        = string
  sensitive   = true
}

variable "vm_admin_username" {
  description = "Admin username for virtual machines"
  type        = string
  default     = "azureuser"
}

variable "vm_admin_password" {
  description = "Admin password for virtual machines"
  type        = string
  sensitive   = true
}
