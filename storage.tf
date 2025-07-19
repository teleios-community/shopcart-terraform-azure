module "storage" {
  source  = "app.terraform.io/Teleios/storage/azure"
  version = "~> 1.0"

  name                = "${local.name_prefix}storage"
  location            = var.location
  resource_group_name = module.resource_group.name
  
  # Storage configuration
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_replication_type
  
  tags = local.common_tags
}
