module "vnet" {
  source  = "app.terraform.io/Teleios/vnet/azure"
  version = "~> 1.0"

  name                = "${local.name_prefix}-vnet"
  location            = var.location
  resource_group_name = module.resource_group.name
  address_space       = var.vnet_address_space
  
  subnets = var.subnet_config

  tags = local.common_tags
}
