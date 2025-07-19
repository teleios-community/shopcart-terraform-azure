# Get current Azure configuration
data "azurerm_client_config" "current" {}

# Get available VM sizes in the region
data "azurerm_virtual_machine_sizes" "available" {
  location = var.location
}

# Get latest Ubuntu image
data "azurerm_platform_image" "ubuntu" {
  location  = var.location
  publisher = "Canonical"
  offer     = "0001-com-ubuntu-server-focal"
  sku       = "20_04-lts-gen2"
}
