variable "resource_group_name" {
  description = "The name of the existing Azure Resource Group where the NSGs will be deployed."
  type        = string
}

variable "environment" {
  description = "The environment name (e.g., 'dev', 'prod') to prefix NSG names."
  type        = string
}

variable "location" {
  description = "The Azure region where the resources will be deployed."
  type        = string
}


variable "web_ingress_rules" {
  description = "Example web ingress rules."
  type = list(object({
    name                       = string
    priority                   = number
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
  default = [
    {
      name                       = "AllowHTTP"
      priority                   = 100
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "80"
      source_address_prefix      = "Internet"
      destination_address_prefix = "*"
    },
    {
      name                       = "AllowHTTPS"
      priority                   = 110
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "Internet"
      destination_address_prefix = "*"
    }
  ]
}

variable "app_ingress_rules" {
  description = "Example app ingress rules."
  type = list(object({
    name                       = string
    priority                   = number
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
  default = [
    {
      name                       = "AllowWebToApp"
      priority                   = 100
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "8080"
      source_address_prefix      = "10.0.0.0/22"
      destination_address_prefix = "*"
    }
  ]
}

variable "db_ingress_rules" {
  description = "Example db ingress rules."
  type = list(object({
    name                       = string
    priority                   = number
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
  default = [
    {
      name                       = "AllowAppToDB"
      priority                   = 100
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "5432"
      source_address_prefix      = "10.0.0.0/22"
      destination_address_prefix = "*"
    }
  ]
}

variable "tags" {
  description = "A map of tags to assign to the resources."
  type        = map(string)
  default     = {}
}
