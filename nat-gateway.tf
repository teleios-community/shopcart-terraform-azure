module "nat_gateway" {
  source  = "app.terraform.io/Teleios/nat-gateway/azure"
  version = "~> 1.0"

  name                = "${local.name_prefix}-natgw"
  location            = var.location
  resource_group_name = module.resource_group.name
  
  # Dependencies from VNet module
  subnet_ids = [module.vnet.subnet_ids["app"], module.vnet.subnet_ids["data"]]
  
  tags = local.common_tags
}
