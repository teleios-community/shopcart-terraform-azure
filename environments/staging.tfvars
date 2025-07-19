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
