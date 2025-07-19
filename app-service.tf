module "app_service" {
  source  = "app.terraform.io/Teleios/app-service/azure"
  version = "~> 1.0"

  name                = "${local.name_prefix}-app"
  location            = var.location
  resource_group_name = module.resource_group.name
  
  # App Service Plan configuration
  sku = var.app_service_plan_sku
  
  tags = local.common_tags
}
