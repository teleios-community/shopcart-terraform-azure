# Terraform Azure VNet Module
This module creates an Azure Virtual Network (VNet) with dynamically defined public subnets and one private subnet. It allows for the optional association of an existing NAT Gateway with the private subnet for outbound internet access.

### Usage
To use this module, include it in your Terraform configuration and provide the required variables.

```

module "vnet_example" {
  source              = "../../" # Points to the root of your module (one level up) in this case, we point to the github url

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
```

## Inputs

| **Name**                | **Description**                                                                                | **Type**                                        | **Default** | **Required** |
| ----------------------- | ---------------------------------------------------------------------------------------------- | ----------------------------------------------- | ----------- | ------------ |
| `resource_group_name`   | The name of the Azure Resource Group to deploy resources into.                                 | `string`                                        | n/a         | ✅ Yes        |
| `location`              | The Azure region where the resources will be deployed.                                         | `string`                                        | n/a         | ✅ Yes        |
| `vnet_name`             | The name of the Virtual Network (VNet).                                                        | `string`                                        | n/a         | ✅ Yes        |
| `vnet_address_space`    | The CIDR block for the Virtual Network (e.g., `10.0.0.0/16`).                                  | `string`                                        | n/a         | ✅ Yes        |
| `public_subnets`        | A map defining the public subnets to create. Each key is an identifier with `name` and `cidr`. | `map(object({ name = string, cidr = string }))` | n/a         | ✅ Yes        |
| `private_subnet_1_name` | The name of the private subnet.                                                                | `string`                                        | n/a         | ✅ Yes        |
| `private_subnet_1_cidr` | The CIDR block for the private subnet (e.g., `10.0.3.0/24`).                                   | `string`                                        | n/a         | ✅ Yes        |
| `nat_gateway_id`        | The ID of the NAT Gateway to associate with the private subnet. `null` if no NAT is used.      | `string`                                        | `null`      | ❌ No         |
| `tags`                  | A map of tags to assign to the resources.                                                      | `map(string)`                                   | `{}`        | ❌ No         |




## Outputs

| **Name**              | **Description**                                                              |
| --------------------- | ---------------------------------------------------------------------------- |
| `vnet_id`             | The ID of the Virtual Network.                                               |
| `vnet_name`           | The name of the Virtual Network.                                             |
| `public_subnet_ids`   | A map of IDs for the created public subnets (keyed by the input map keys).   |
| `public_subnet_names` | A map of names for the created public subnets (keyed by the input map keys). |
| `private_subnet_1_id` | The ID of the private subnet.                                                |
| `private_subnet_ids`  | A list of IDs for all private subnets.                                       |
| `resource_group_name` | The name of the resource group used by the module.                           |
