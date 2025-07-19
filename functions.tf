module "functions" {
  source  = "app.terraform.io/Teleios/functions/azure"
  version = "~> 1.0"

  name                = "${local.name_prefix}-func"
  location            = var.location
  resource_group_name = module.resource_group.name
  
  # Dependencies from storage module
  storage_account_name       = module.storage.account_name
  storage_account_access_key = module.storage.primary_access_key
  
  tags = local.common_tags
}
