module "redis" {
  source  = "app.terraform.io/Teleios/redis/azure"
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
