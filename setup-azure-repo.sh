#!/bin/bash

# Script to set up the shopcart-terraform-azure implementation repository
# This creates the enterprise-grade structure for consuming Teleios Azure modules

set -e

REPO_NAME="shopcart-terraform-azure"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🚀 Setting up Teleios E-Commerce Azure Infrastructure Repository: ${REPO_NAME}"
echo "📁 Creating directory structure..."

# # Create main repository directory
# mkdir -p "${REPO_NAME}"
# cd "${REPO_NAME}"

# Create directory structure
mkdir -p environments
mkdir -p .github/workflows
mkdir -p docs

echo "📝 Creating shared Terraform configuration files..."

# Create terraform.tf (Terraform Cloud configuration)
cat > terraform.tf << 'EOF'
terraform {
  required_version = ">= 1.5"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }

  cloud {
    organization = "teleios"
    workspaces {
      tags = ["e-commerce", "azure"]
    }
  }
}

# Configure the Azure Provider
provider "azurerm" {
  features {}
}
EOF

# Create variables.tf (All variable definitions)
cat > variables.tf << 'EOF'
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
EOF

# Create locals.tf (Common local values)
cat > locals.tf << 'EOF'
locals {
  # Common naming convention
  name_prefix = "${var.project_name}-${var.environment}"
  
  # Common tags applied to all resources
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
    Owner       = "Teleios-DevOps"
    CreatedBy   = "shopcart-terraform-azure"
  }

  # Resource group name
  resource_group_name = "${local.name_prefix}-rg"

  # Computed values
  location_short = {
    "East US"      = "eus"
    "West US"      = "wus"
    "Central US"   = "cus"
    "North Europe" = "neu"
    "West Europe"  = "weu"
  }

  location_code = local.location_short[var.location]
}
EOF

# Create outputs.tf (All environment outputs)
cat > outputs.tf << 'EOF'
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
EOF

# Create data.tf (Common data sources)
cat > data.tf << 'EOF'
# Get current Azure configuration
data "azurerm_client_config" "current" {}

# Get available VM sizes in the region
data "azurerm_virtual_machine_sizes" "available" {
  location = var.location
}

# Get latest Ubuntu image
data "azurerm_platform_image" "ubuntu" {
  location  = var.location
  publisher = "Canonical"
  offer     = "0001-com-ubuntu-server-focal"
  sku       = "20_04-lts-gen2"
}
EOF

echo "🏗️ Creating resource-specific configuration files..."

# Create resource group configuration
cat > resource-group.tf << 'EOF'
module "resource_group" {
  source  = "app.terraform.io/teleios-devops/resource-group/azure"
  version = "~> 1.0"

  name     = local.resource_group_name
  location = var.location
  
  tags = local.common_tags
}
EOF

# Create virtual network configuration
cat > vnet.tf << 'EOF'
module "vnet" {
  source  = "app.terraform.io/teleios-devops/vnet/azure"
  version = "~> 1.0"

  name                = "${local.name_prefix}-vnet"
  location            = var.location
  resource_group_name = module.resource_group.name
  address_space       = var.vnet_address_space
  
  subnets = var.subnet_config

  tags = local.common_tags
}
EOF

# Create network security groups configuration
cat > nsg.tf << 'EOF'
module "nsg" {
  source  = "app.terraform.io/teleios-devops/nsg/azure"
  version = "~> 1.0"

  resource_group_name = module.resource_group.name
  location           = var.location
  environment        = var.environment
  
  # Dependencies from VNet module
  subnet_ids = module.vnet.subnet_ids
  
  # Security rules
  web_security_rules = var.web_security_rules
  
  tags = local.common_tags
}
EOF

# Create application gateway configuration
cat > app-gateway.tf << 'EOF'
module "app_gateway" {
  source  = "app.terraform.io/teleios-devops/app-gateway/azure"
  version = "~> 1.0"

  name                = "${local.name_prefix}-appgw"
  location            = var.location
  resource_group_name = module.resource_group.name
  
  # Dependencies from other modules
  subnet_id = module.vnet.subnet_ids["web"]
  
  tags = local.common_tags
}
EOF

# Create NAT gateway configuration
cat > nat-gateway.tf << 'EOF'
module "nat_gateway" {
  source  = "app.terraform.io/teleios-devops/nat-gateway/azure"
  version = "~> 1.0"

  name                = "${local.name_prefix}-natgw"
  location            = var.location
  resource_group_name = module.resource_group.name
  
  # Dependencies from VNet module
  subnet_ids = [module.vnet.subnet_ids["app"], module.vnet.subnet_ids["data"]]
  
  tags = local.common_tags
}
EOF

# Create virtual machine scale set configuration
cat > vm.tf << 'EOF'
module "vm" {
  source  = "app.terraform.io/teleios-devops/vm/azure"
  version = "~> 1.0"

  name                = "${local.name_prefix}-vmss"
  location            = var.location
  resource_group_name = module.resource_group.name
  
  # Dependencies from other modules
  subnet_id = module.vnet.subnet_ids["app"]
  nsg_id    = module.nsg.app_nsg_id
  
  # VM configuration
  sku                 = var.vmss_sku
  capacity            = var.vmss_capacity
  admin_username      = var.vm_admin_username
  admin_password      = var.vm_admin_password
  
  tags = local.common_tags
}
EOF

# Create container instances configuration
cat > container-instances.tf << 'EOF'
module "container_instances" {
  source  = "app.terraform.io/teleios-devops/container-instances/azure"
  version = "~> 1.0"

  name                = "${local.name_prefix}-aci"
  location            = var.location
  resource_group_name = module.resource_group.name
  
  # Dependencies from other modules
  subnet_id = module.vnet.subnet_ids["app"]
  
  tags = local.common_tags
}
EOF

# Create app service configuration
cat > app-service.tf << 'EOF'
module "app_service" {
  source  = "app.terraform.io/teleios-devops/app-service/azure"
  version = "~> 1.0"

  name                = "${local.name_prefix}-app"
  location            = var.location
  resource_group_name = module.resource_group.name
  
  # App Service Plan configuration
  sku = var.app_service_plan_sku
  
  tags = local.common_tags
}
EOF

# Create Azure Functions configuration
cat > functions.tf << 'EOF'
module "functions" {
  source  = "app.terraform.io/teleios-devops/functions/azure"
  version = "~> 1.0"

  name                = "${local.name_prefix}-func"
  location            = var.location
  resource_group_name = module.resource_group.name
  
  # Dependencies from storage module
  storage_account_name       = module.storage.account_name
  storage_account_access_key = module.storage.primary_access_key
  
  tags = local.common_tags
}
EOF

# Create SQL database configuration
cat > sql.tf << 'EOF'
module "sql" {
  source  = "app.terraform.io/teleios-devops/sql/azure"
  version = "~> 1.0"

  server_name         = "${local.name_prefix}-sql"
  database_name       = "${local.name_prefix}-db"
  location            = var.location
  resource_group_name = module.resource_group.name
  
  # Dependencies from VNet module
  subnet_id = module.vnet.subnet_ids["data"]
  
  # SQL configuration
  administrator_login    = var.sql_server_config.administrator_login
  administrator_password = var.sql_administrator_password
  sku_name              = var.sql_server_config.sku_name
  max_size_gb           = var.sql_server_config.max_size_gb
  
  tags = local.common_tags
}
EOF

# Create Redis cache configuration
cat > redis.tf << 'EOF'
module "redis" {
  source  = "app.terraform.io/teleios-devops/redis/azure"
  version = "~> 1.0"

  name                = "${local.name_prefix}-redis"
  location            = var.location
  resource_group_name = module.resource_group.name
  
  # Dependencies from VNet module
  subnet_id = module.vnet.subnet_ids["data"]
  
  # Redis configuration
  capacity = var.redis_config.capacity
  family   = var.redis_config.family
  sku_name = var.redis_config.sku_name
  
  tags = local.common_tags
}
EOF

# Create storage account configuration
cat > storage.tf << 'EOF'
module "storage" {
  source  = "app.terraform.io/teleios-devops/storage/azure"
  version = "~> 1.0"

  name                = "${local.name_prefix}storage"
  location            = var.location
  resource_group_name = module.resource_group.name
  
  # Storage configuration
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_replication_type
  
  tags = local.common_tags
}
EOF

# Create Cosmos DB configuration
cat > cosmos-db.tf << 'EOF'
module "cosmosdb" {
  source  = "app.terraform.io/teleios-devops/cosmos-db/azure"
  version = "~> 1.0"

  name                = "${local.name_prefix}-cosmos"
  location            = var.location
  resource_group_name = module.resource_group.name
  
  # Cosmos DB configuration
  offer_type        = var.cosmosdb_config.offer_type
  consistency_level = var.cosmosdb_config.consistency_level
  throughput        = var.cosmosdb_config.throughput
  
  tags = local.common_tags
}
EOF

echo "🌍 Creating environment-specific configuration files..."

# Create environments directory and files
cat > environments/dev.tfvars << 'EOF'
# Development Environment Configuration
environment = "dev"
location    = "East US"

# Virtual Network Configuration (minimal for cost)
vnet_address_space = ["10.0.0.0/16"]

# VM Scale Set Configuration (cost-optimized)
vmss_sku = "Standard_B1s"
vmss_capacity = {
  min     = 1
  max     = 2
  default = 1
}

# App Service Configuration (minimal)
app_service_plan_sku = {
  tier = "Basic"
  size = "B1"
}

# SQL Configuration (cost-optimized)
sql_server_config = {
  administrator_login = "sqladmin"
  sku_name           = "Basic"
  max_size_gb        = 2
}

# Redis Configuration (minimal)
redis_config = {
  capacity = 0
  family   = "C"
  sku_name = "Basic"
}

# Storage Configuration (local redundancy)
storage_account_tier     = "Standard"
storage_replication_type = "LRS"

# Cosmos DB Configuration (minimal throughput)
cosmosdb_config = {
  offer_type        = "Standard"
  consistency_level = "Session"
  throughput        = 400
}

# Network Security Rules (development-friendly)
web_security_rules = [
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
  },
  {
    name                       = "Allow-SSH"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
]
EOF

cat > environments/staging.tfvars << 'EOF'
# Staging Environment Configuration
environment = "staging"
location    = "East US"

# Virtual Network Configuration
vnet_address_space = ["10.1.0.0/16"]

# VM Scale Set Configuration (intermediate scale)
vmss_sku = "Standard_B2s"
vmss_capacity = {
  min     = 2
  max     = 5
  default = 2
}

# App Service Configuration (standard)
app_service_plan_sku = {
  tier = "Standard"
  size = "S1"
}

# SQL Configuration (standard)
sql_server_config = {
  administrator_login = "sqladmin"
  sku_name           = "S1"
  max_size_gb        = 100
}

# Redis Configuration (standard)
redis_config = {
  capacity = 1
  family   = "C"
  sku_name = "Standard"
}

# Storage Configuration (zone redundancy)
storage_account_tier     = "Standard"
storage_replication_type = "ZRS"

# Cosmos DB Configuration (moderate throughput)
cosmosdb_config = {
  offer_type        = "Standard"
  consistency_level = "Session"
  throughput        = 800
}

# Network Security Rules (more restrictive)
web_security_rules = [
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
EOF

cat > environments/prod.tfvars << 'EOF'
# Production Environment Configuration
environment = "prod"
location    = "East US"

# Virtual Network Configuration (production scale)
vnet_address_space = ["10.2.0.0/16"]

# VM Scale Set Configuration (production scale)
vmss_sku = "Standard_D2s_v3"
vmss_capacity = {
  min     = 3
  max     = 20
  default = 5
}

# App Service Configuration (premium)
app_service_plan_sku = {
  tier = "Premium"
  size = "P1"
}

# SQL Configuration (production)
sql_server_config = {
  administrator_login = "sqladmin"
  sku_name           = "S3"
  max_size_gb        = 500
}

# Redis Configuration (premium)
redis_config = {
  capacity = 2
  family   = "P"
  sku_name = "Premium"
}

# Storage Configuration (geo-redundancy)
storage_account_tier     = "Standard"
storage_replication_type = "GRS"

# Cosmos DB Configuration (high throughput)
cosmosdb_config = {
  offer_type        = "Standard"
  consistency_level = "Session"
  throughput        = 2000
}

# Network Security Rules (production security)
web_security_rules = [
  {
    name                       = "Allow-HTTPS"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
]
EOF

echo "📖 Creating documentation files..."

# Create README.md
cat > README.md << 'EOF'
# Teleios E-Commerce Infrastructure - Azure Implementation

This repository contains the Terraform infrastructure code for deploying the Teleios e-commerce platform on Microsoft Azure. It follows enterprise best practices with modular design, environment-specific configurations, and Terraform Cloud integration.

## 🏗️ Architecture Overview

This implementation creates a scalable e-commerce platform supporting development, staging, and production environments with:

- **Networking**: Virtual Network with public/private subnets, Network Security Groups, Application Gateway, NAT Gateway
- **Compute**: Virtual Machine Scale Sets, Azure Container Instances, App Service, Azure Functions  
- **Data**: Azure SQL Database, Azure Cache for Redis, Storage Accounts, Cosmos DB

## 📁 Repository Structure

```
shopcart-terraform-azure/
├── # SHARED CONFIGURATION
├── terraform.tf              # Terraform Cloud workspace configuration
├── variables.tf              # All variable definitions
├── locals.tf                 # Common local values and logic
├── outputs.tf                # All environment outputs
├── data.tf                   # Common data sources
│
├── # RESOURCE FILES
├── resource-group.tf         # Resource Group module consumption
├── vnet.tf                   # Virtual Network module consumption
├── nsg.tf                    # Network Security Groups module consumption
├── app-gateway.tf            # Application Gateway module consumption
├── nat-gateway.tf            # NAT Gateway module consumption
├── vm.tf                     # Virtual Machine Scale Set module consumption
├── container-instances.tf    # Container Instances module consumption
├── app-service.tf            # App Service module consumption
├── functions.tf              # Azure Functions module consumption
├── sql.tf                    # SQL Database module consumption
├── redis.tf                  # Redis Cache module consumption
├── storage.tf                # Storage Account module consumption
├── cosmos-db.tf              # Cosmos DB module consumption
│
└── # ENVIRONMENT CONFIGS
    └── environments/
        ├── dev.tfvars        # Development configuration
        ├── staging.tfvars    # Staging configuration
        └── prod.tfvars       # Production configuration
```

## 🚀 Quick Start

### Prerequisites

1. **Terraform Cloud Account**: Set up workspaces for dev, staging, and prod
2. **Azure Subscription**: Active Azure subscription with contributor access
3. **Module Access**: Access to Teleios private module registry

### Environment Setup

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd shopcart-terraform-azure
   ```

2. **Configure Terraform Cloud Variables**:
   Set these sensitive variables in your Terraform Cloud workspace:
   - `TF_VAR_sql_administrator_password` (sensitive)
   - `TF_VAR_vm_admin_password` (sensitive)
   - `ARM_CLIENT_ID` (Azure Service Principal)
   - `ARM_CLIENT_SECRET` (Azure Service Principal Secret)
   - `ARM_SUBSCRIPTION_ID` (Azure Subscription ID)
   - `ARM_TENANT_ID` (Azure Tenant ID)

3. **Initialize Terraform**:
   ```bash
   terraform init
   ```

### Deployment Commands

#### Development Environment
```bash
terraform plan -var-file="environments/dev.tfvars"
terraform apply -var-file="environments/dev.tfvars"
```

#### Staging Environment  
```bash
terraform plan -var-file="environments/staging.tfvars"
terraform apply -var-file="environments/staging.tfvars"
```

#### Production Environment
```bash
terraform plan -var-file="environments/prod.tfvars"
terraform apply -var-file="environments/prod.tfvars"
```

## 🎯 Environment Configurations

### Development (`dev.tfvars`)
- **Cost-optimized**: Basic SKUs, minimal redundancy
- **VM Scale Set**: B1s instances, 1-2 capacity
- **SQL Database**: Basic tier, 2GB
- **Redis**: Basic tier, C0 cache
- **Storage**: Local redundancy (LRS)

### Staging (`staging.tfvars`)
- **Intermediate scale**: Standard SKUs, zone redundancy
- **VM Scale Set**: B2s instances, 2-5 capacity  
- **SQL Database**: S1 tier, 100GB
- **Redis**: Standard tier, C1 cache
- **Storage**: Zone redundancy (ZRS)

### Production (`prod.tfvars`)
- **Production-ready**: Premium SKUs, geo-redundancy
- **VM Scale Set**: D2s_v3 instances, 3-20 capacity
- **SQL Database**: S3 tier, 500GB
- **Redis**: Premium tier, P1 cache
- **Storage**: Geo redundancy (GRS)

## 🔧 Module Dependencies

The infrastructure components have explicit dependencies:

```
Resource Group
    ↓
Virtual Network → Network Security Groups
    ↓                    ↓
App Gateway ←→ VM Scale Set ←→ Storage Account
    ↓                    ↓           ↓
Container Instances  App Service  Functions
    ↓                    ↓           ↓
SQL Database ←→ Redis Cache ←→ Cosmos DB
```

## 🔐 Security Considerations

- **Network Segmentation**: Separate subnets for web, app, and data tiers
- **Security Groups**: Restrictive rules with least privilege access
- **Secrets Management**: Sensitive data stored in Terraform Cloud variables
- **SSL/TLS**: HTTPS enforced across all public endpoints

## 📊 Cost Optimization

- **Environment Scaling**: Appropriate sizing for each environment
- **Auto Scaling**: Dynamic scaling based on demand
- **Reserved Instances**: Consider for production workloads
- **Storage Tiers**: Appropriate replication levels per environment

## 🔄 CI/CD Integration

This repository integrates with Terraform Cloud for:
- **Automated Planning**: Pull request triggered plans
- **Secure Apply**: Protected production deployments
- **State Management**: Remote state with locking
- **Variable Management**: Centralized sensitive data

## 📈 Monitoring & Observability

Post-deployment monitoring setup:
- **Application Insights**: Application performance monitoring
- **Azure Monitor**: Infrastructure metrics and logs
- **Log Analytics**: Centralized logging
- **Alerts**: Proactive issue detection

## 🤝 Contributing

1. Create feature branch from main
2. Make changes following established patterns
3. Test changes in development environment
4. Submit pull request with detailed description
5. Ensure all CI/CD checks pass

## 📞 Support

- **Team**: Teleios DevOps Team
- **Documentation**: See `/docs` directory
- **Issues**: Create GitHub issues for bugs/features

---

**Built with ❤️ by the Teleios DevOps Team**
EOF

# Create ARCHITECTURE.md
cat > ARCHITECTURE.md << 'EOF'
# Azure E-Commerce Platform Architecture

## 🏗️ High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     Teleios E-Commerce Platform                 │
├─────────────────┬─────────────────┬─────────────────────────────┤
│   NETWORKING    │     COMPUTE     │            DATA             │
│                 │                 │                             │
│ • Virtual Net   │ • VM Scale Sets │ • Azure SQL Database       │
│ • Subnets       │ • App Service   │ • Redis Cache               │
│ • App Gateway   │ • Functions     │ • Storage Account           │
│ • NAT Gateway   │ • Containers    │ • Cosmos DB                 │
│ • Security Grps │                 │                             │
└─────────────────┴─────────────────┴─────────────────────────────┘
```

## 🌐 Network Architecture

### Virtual Network Layout
- **Address Space**: Environment-specific CIDR blocks
- **Subnets**: 
  - Web Tier (10.x.1.0/24) - Public-facing components
  - App Tier (10.x.2.0/24) - Application logic
  - Data Tier (10.x.3.0/24) - Database and storage

### Security Architecture
- **Network Security Groups**: Tier-specific traffic rules
- **Application Gateway**: Load balancing and SSL termination
- **NAT Gateway**: Secure outbound connectivity for private subnets

## 💻 Compute Architecture

### Virtual Machine Scale Sets
- **Auto Scaling**: Dynamic capacity based on demand
- **Health Probes**: Automatic unhealthy instance replacement
- **Load Distribution**: Even workload distribution

### App Service & Functions
- **Managed Platform**: Serverless compute options
- **Integrated CI/CD**: Direct deployment integration
- **Auto Scaling**: Built-in scaling capabilities

## 💾 Data Architecture

### Azure SQL Database
- **Multi-tier**: Appropriate sizing per environment
- **Backup Strategy**: Automated backups with retention
- **High Availability**: Configurable redundancy

### Caching Strategy
- **Redis**: Session state and application caching
- **CDN Integration**: Static content delivery

### Storage Strategy
- **Blob Storage**: Application assets and media
- **File Storage**: Shared application data
- **Cosmos DB**: Document and NoSQL data

## 🔄 Deployment Architecture

### Environment Progression
```
Development → Staging → Production
     ↓           ↓          ↓
  Basic SKUs  Standard   Premium
  Single AZ   Multi-AZ   Multi-AZ
  Local Rep   Zone Rep   Geo Rep
```

### Infrastructure as Code
- **Modular Design**: Reusable components
- **Version Control**: Git-based change management
- **State Management**: Terraform Cloud backend

## 📊 Scaling Strategy

### Horizontal Scaling
- **VM Scale Sets**: Automatic instance scaling
- **App Service**: Built-in scaling rules
- **Database**: Read replicas for performance

### Vertical Scaling
- **Environment-specific**: Appropriate sizing
- **Performance Monitoring**: Metrics-driven decisions
- **Cost Optimization**: Right-sizing per workload

## 🔐 Security Architecture

### Network Security
- **Zero Trust**: Explicit verification required
- **Micro-segmentation**: Subnet-level isolation
- **Traffic Inspection**: NSG rule enforcement

### Identity & Access
- **Azure AD Integration**: Centralized authentication
- **Role-Based Access**: Least privilege principle
- **Service Principals**: Automated access management

### Data Protection
- **Encryption**: At rest and in transit
- **Key Management**: Azure Key Vault integration
- **Backup Strategy**: Automated and tested

## 📈 Monitoring Architecture

### Application Monitoring
- **Application Insights**: Performance and usage
- **Custom Metrics**: Business-specific KPIs
- **Distributed Tracing**: End-to-end visibility

### Infrastructure Monitoring
- **Azure Monitor**: Resource metrics
- **Log Analytics**: Centralized logging
- **Alerting**: Proactive issue detection

## 🌍 Multi-Environment Strategy

### Development
- **Purpose**: Feature development and testing
- **Scale**: Minimal resources for cost optimization
- **Data**: Synthetic test data

### Staging
- **Purpose**: Integration testing and validation
- **Scale**: Production-like but reduced capacity
- **Data**: Sanitized production-like data

### Production
- **Purpose**: Live customer traffic
- **Scale**: Full capacity with auto-scaling
- **Data**: Real customer data with full backup

## 🔄 Disaster Recovery

### Backup Strategy
- **Database**: Automated backups with geo-replication
- **Storage**: Cross-region replication
- **Configuration**: Infrastructure as Code recovery

### Recovery Procedures
- **RTO Target**: < 4 hours for production
- **RPO Target**: < 1 hour data loss maximum
- **Testing**: Regular DR drills and validation

---

This architecture provides a robust, scalable, and secure foundation for the Teleios e-commerce platform on Azure.
EOF

# Create GitHub Actions workflow
cat > .github/workflows/deploy.yml << 'EOF'
name: 'Terraform Deploy'

on:
  push:
    branches:
      - main
      - develop
  pull_request:
    branches:
      - main

permissions:
  contents: read
  pull-requests: write

jobs:
  terraform:
    name: 'Terraform'
    runs-on: ubuntu-latest
    environment: ${{ github.ref == 'refs/heads/main' && 'production' || 'development' }}

    defaults:
      run:
        shell: bash

    steps:
    - name: Checkout
      uses: actions/checkout@v4

    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v3
      with:
        cli_config_credentials_token: ${{ secrets.TF_API_TOKEN }}

    - name: Terraform Format
      id: fmt
      run: terraform fmt -check

    - name: Terraform Init
      id: init
      run: terraform init

    - name: Terraform Validate
      id: validate
      run: terraform validate -no-color

    - name: Terraform Plan
      id: plan
      if: github.event_name == 'pull_request'
      run: |
        if [ "${{ github.ref }}" == "refs/heads/main" ]; then
          terraform plan -var-file="environments/prod.tfvars" -no-color -input=false
        else
          terraform plan -var-file="environments/dev.tfvars" -no-color -input=false
        fi
      continue-on-error: true

    - name: Update Pull Request
      uses: actions/github-script@v7
      if: github.event_name == 'pull_request'
      env:
        PLAN: ${{ steps.plan.outputs.stdout }}
      with:
        script: |
          const output = `#### Terraform Format and Style 🖌\`${{ steps.fmt.outcome }}\`
          #### Terraform Initialization ⚙️\`${{ steps.init.outcome }}\`
          #### Terraform Validation 🤖\`${{ steps.validate.outcome }}\`
          #### Terraform Plan 📖\`${{ steps.plan.outcome }}\`

          <details><summary>Show Plan</summary>

          \`\`\`terraform\n
          ${process.env.PLAN}
          \`\`\`

          </details>

          *Pushed by: @${{ github.actor }}, Action: \`${{ github.event_name }}\`*`;

          github.rest.issues.createComment({
            issue_number: context.issue.number,
            owner: context.repo.owner,
            repo: context.repo.repo,
            body: output
          })

    - name: Terraform Plan Status
      if: steps.plan.outcome == 'failure'
      run: exit 1

    - name: Terraform Apply
      if: github.ref == 'refs/heads/main' && github.event_name == 'push'
      run: terraform apply -var-file="environments/prod.tfvars" -auto-approve -input=false
EOF

echo "✅ Repository structure created successfully!"
echo ""
echo "📋 Summary of created files:"
echo "├── terraform.tf (Terraform Cloud configuration)"
echo "├── variables.tf (All variable definitions)"
echo "├── locals.tf (Common local values)"
echo "├── outputs.tf (All environment outputs)"
echo "├── data.tf (Common data sources)"
echo "├── resource-group.tf (Resource Group module)"
echo "├── vnet.tf (Virtual Network module)"
echo "├── nsg.tf (Network Security Groups module)"
echo "├── app-gateway.tf (Application Gateway module)"
echo "├── nat-gateway.tf (NAT Gateway module)"
echo "├── vm.tf (Virtual Machine Scale Set module)"
echo "├── container-instances.tf (Container Instances module)"
echo "├── app-service.tf (App Service module)"
echo "├── functions.tf (Azure Functions module)"
echo "├── sql.tf (SQL Database module)"
echo "├── redis.tf (Redis Cache module)"
echo "├── storage.tf (Storage Account module)"
echo "├── cosmos-db.tf (Cosmos DB module)"
echo "├── environments/"
echo "│   ├── dev.tfvars (Development configuration)"
echo "│   ├── staging.tfvars (Staging configuration)"
echo "│   └── prod.tfvars (Production configuration)"
echo "├── README.md (Complete documentation)"
echo "├── ARCHITECTURE.md (Architecture overview)"
echo "└── .github/workflows/deploy.yml (CI/CD pipeline)"
echo ""
echo "🚀 Next steps:"
echo "1. Initialize git repository: git init"
echo "2. Add remote origin: git remote add origin <repository-url>"
echo "3. Commit files: git add . && git commit -m 'Initial Azure implementation structure'"
echo "4. Push to repository: git push -u origin main"
echo "5. Configure Terraform Cloud workspaces"
echo "6. Set up sensitive variables in Terraform Cloud"
echo "7. Start deploying to development environment"
echo ""
echo "🎯 The repository is ready for the team to start building!"
EOF