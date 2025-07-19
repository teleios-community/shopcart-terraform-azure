module "cosmosdb" {
  source  = "app.terraform.io/Teleios/cosmos-db/azure"
  version = "~> 1.0"

  name                = "${local.name_prefix}-cosmos"
  location            = var.location
  resource_group_name = module.resource_group.name
  
  # Cosmos DB configuration
  offer_type        = var.cosmosdb_config.offer_type
  consistency_level = var.cosmosdb_config.consistency_level
  throughput        = var.cosmosdb_config.throughput
  
  tags = local.common_tags
}
