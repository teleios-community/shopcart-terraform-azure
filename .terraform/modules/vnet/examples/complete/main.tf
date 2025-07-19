provider "azurerm" {
  features {} # Required for the AzureRM provider
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.30"
    }
  }
}

module "vnet_example" {
  source              = "../../" # Points to the root of your module (one level up)
  resource_group_name = "terraform-vnet-teleios-rg"
  location            = "eastus"
  vnet_name           = "example-vnet"
  vnet_address_space  = "10.0.0.0/22"

  public_subnets = {
    "public1" = { name = "example-public-subnet-1", cidr = "10.0.0.0/24" },
    "public2" = { name = "example-public-subnet-2", cidr = "10.0.2.0/24" }
  }

  private_subnet_1_name = "example-private-subnet-1"
  private_subnet_1_cidr = "10.0.4.0/24"

  # Nat gateway id to be adjusted to match nat_gateway_id from module
  nat_gateway_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mock-rg/providers/Microsoft.Network/natGateways/mock-nat-gateway"

  tags = {
    Environment = "Example"
    Project     = "VNetModuleTest"
  }
}