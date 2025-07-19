module "vm" {
  source  = "app.terraform.io/Teleios/vm/azure"
  version = "~> 1.0"

  name                = "${local.name_prefix}-vmss"
  location            = var.location
  resource_group_name = module.resource_group.name
  
  # Dependencies from other modules
  subnet_id = module.vnet.subnet_ids["app"]
  nsg_id    = module.nsg.app_nsg_id
  
  # VM configuration
  sku                 = var.vmss_sku
  capacity            = var.vmss_capacity
  admin_username      = var.vm_admin_username
  admin_password      = var.vm_admin_password
  
  tags = local.common_tags
}
