module "app_gateway" {
  source  = "app.terraform.io/Teleios/app-gateway/azure"
  version = "~> 1.0"

  name                = "${local.name_prefix}-appgw"
  location            = var.location
  resource_group_name = module.resource_group.name
  
  # Dependencies from other modules
  subnet_id = module.vnet.subnet_ids["web"]
  
  tags = local.common_tags
}
