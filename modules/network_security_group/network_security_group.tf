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
variable "nsg_name" {}
variable "location" {}


variable "tags" {}

resource "azurerm_network_security_group" "network_security_group" {
    name                        = var.nsg_name
    resource_group_name         = var.rg_name
    location                    = var.location
    tags                        = var.tags
}

# Outputs
output "name" {
  value = azurerm_network_security_group.network_security_group.name
}

output "id" {
  value = azurerm_network_security_group.network_security_group.id
}
