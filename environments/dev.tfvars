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
