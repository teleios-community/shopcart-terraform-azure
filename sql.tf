module "sql" {
  source  = "app.terraform.io/Teleios/sql/azure"
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
