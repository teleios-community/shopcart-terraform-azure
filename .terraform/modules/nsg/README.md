# Terraform Azure Network Security Group (NSG) Module
This module creates Azure Network Security Groups (NSGs) for common application tiers: web, application, and database. It allows you to define custom inbound security rules for each NSG.

Usage
To use this module, include it in your Terraform configuration and provide the required variables, including the ingress rules for each tier.

module "security_groups" {
  source = "app.terraform.io/your-org/nsg/azure" # Replace 'your-org' with your Terraform Cloud organization name
  version = "1.0.0" # Use the appropriate version

  resource_group_name = "my-ecommerce-rg" # Name of an existing resource group
  environment         = "dev"

  web_ingress_rules = [
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

  app_ingress_rules = [
    {
      name                       = "AllowWebToApp"
      priority                   = 100
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "8080"
      source_address_prefix      = "10.0.1.0/24" # Example: Source from a web subnet
      destination_address_prefix = "*"
    }
  ]

  db_ingress_rules = [
    {
      name                       = "AllowAppToDB"
      priority                   = 100
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "5432" # PostgreSQL default port
      source_address_prefix      = "10.0.3.0/24" # Example: Source from an app subnet
      destination_address_prefix = "*"
    }
  ]

  tags = {
    Environment = "Dev"
    Project     = "E-Commerce"
  }
}

## Inputs
| Name                  | Description                                                                     | Type                                                                                                                                                                                                      | Default | Required |
| --------------------- | ------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- | -------- |
| `resource_group_name` | The name of the existing Azure Resource Group where the NSGs will be deployed.  | `string`                                                                                                                                                                                                  | n/a     | ✅ Yes    |
| `environment`         | The environment name (e.g., `dev`, `prod`) to prefix NSG names.                 | `string`                                                                                                                                                                                                  | n/a     | ✅ Yes    |
| `web_ingress_rules`   | A list of objects defining inbound security rules for the web tier NSG.         | `list(object({ name = string, priority = number, protocol = string, source_port_range = string, destination_port_range = string, source_address_prefix = string, destination_address_prefix = string }))` | `[]`    | ❌ No     |
| `app_ingress_rules`   | A list of objects defining inbound security rules for the application tier NSG. | `list(object({ name = string, priority = number, protocol = string, source_port_range = string, destination_port_range = string, source_address_prefix = string, destination_address_prefix = string }))` | `[]`    | ❌ No     |
| `db_ingress_rules`    | A list of objects defining inbound security rules for the database tier NSG.    | `list(object({ name = string, priority = number, protocol = string, source_port_range = string, destination_port_range = string, source_address_prefix = string, destination_address_prefix = string }))` | `[]`    | ❌ No     |
| `tags`                | A map of tags to assign to the resources.                                       | `map(string)`                                                                                                                                                                                             | `{}`    | ❌ No     |

## Outputs

| Name           | Description                                              |
| -------------- | -------------------------------------------------------- |
| `web_nsg_id`   | The ID of the web tier Network Security Group.           |
| `app_nsg_id`   | The ID of the application tier Network Security Group.   |
| `db_nsg_id`    | The ID of the database tier Network Security Group.      |
| `web_nsg_name` | The name of the web tier Network Security Group.         |
| `app_nsg_name` | The name of the application tier Network Security Group. |
| `db_nsg_name`  | The name of the database tier Network Security Group.    |

