variable "resource_group_name" {
  description = "The name of the Azure Resource Group to deploy resources into."
  type        = string
}

variable "location" {
  description = "The Azure region where the resources will be deployed."
  type        = string
}

variable "vnet_name" {
  description = "The name of the Virtual Network (VNet)."
  type        = string
}

variable "vnet_address_space" {
  description = "The CIDR block for the Virtual Network (e.g., '10.0.0.0/16')."
  type        = string
}

variable "public_subnets" {
  description = "A map of public subnet configurations (name and CIDR)."
  type = map(object({
    name = string
    cidr = string
  }))
  # Example:
  # public_subnets = {
  #   "public1" = { name = "public-subnet-1", cidr = "10.0.1.0/24" },
  #   "public2" = { name = "public-subnet-2", cidr = "10.0.2.0/24" }
  # }
}

variable "private_subnet_1_name" {
  description = "The name of the private subnet."
  type        = string
}

variable "private_subnet_1_cidr" {
  description = "The CIDR block for the private subnet (e.g., '10.0.3.0/24')."
  type        = string
}

variable "nat_gateway_id" {
  description = "The ID of the NAT Gateway to associate with the private subnet. Leave null if no NAT Gateway association is desired."
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to assign to the resources."
  type        = map(string)
  default     = {} # Provide a default empty map if no tags are provided.
}