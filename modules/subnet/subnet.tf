terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.12.0"
    }
  }
  required_version = ">= 1.1.0"
}



variable "rg_name"{}
variable "vnet_name"{}
variable "subnet_name" {}
variable "snet_address_prefixes" {}

variable "tags" {}


resource "azurerm_subnet" "subnet" {

  name                 = var.subnet_name
  resource_group_name  = var.rg_name
  virtual_network_name = var.vnet_name
  address_prefixes     = var.snet_address_prefixes

  delegation {
    name = "delegation-sqlmi"

    service_delegation {
      name = "Microsoft.Sql/managedInstances"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
        "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"
      ]
    }
  }
}


#Output
output "id" {
  value = azurerm_subnet.subnet.id
}
