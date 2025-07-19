locals {
  # Common naming convention
  name_prefix = "${var.project_name}-${var.environment}"
  
  # Common tags applied to all resources
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
    Owner       = "Teleios-DevOps"
    CreatedBy   = "shopcart-terraform-azure"
  }

  # Resource group name
  resource_group_name = "${local.name_prefix}-rg"

  # Computed values
  location_short = {
    "East US"      = "eus"
    "West US"      = "wus"
    "Central US"   = "cus"
    "North Europe" = "neu"
    "West Europe"  = "weu"
  }

  location_code = local.location_short[var.location]
}
