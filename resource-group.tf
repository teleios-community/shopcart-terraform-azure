module "resource_group" {
  source  = "app.terraform.io/Teleios/resource-group/azure"
  version = "~> 1.0"

  name     = local.resource_group_name
  location = var.location
  
  tags = local.common_tags
}
