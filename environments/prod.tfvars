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
