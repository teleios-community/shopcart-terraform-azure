module "nsg" {
  source  = "app.terraform.io/Teleios/nsg/azure"
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
