terraform {
  required_version = ">= 1.5"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }

  cloud {
    organization = "teleios"
    workspaces { 
      project = "Teleios"
    }
  }
}

# Configure the Azure Provider
provider "azurerm" {
  features {}
}
