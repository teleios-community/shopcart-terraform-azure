module "container_instances" {
  source  = "app.terraform.io/Teleios/container-instances/azure"
  version = "~> 1.0"

  name                = "${local.name_prefix}-aci"
  location            = var.location
  resource_group_name = module.resource_group.name
  
  # Dependencies from other modules
  subnet_id = module.vnet.subnet_ids["app"]
  
  tags = local.common_tags
}
