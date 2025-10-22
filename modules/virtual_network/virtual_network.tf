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
variable "location" {}
variable "vnet_name" {}

variable "tags" {}
variable "address_space" {}
resource "azurerm_virtual_network" "vnet" {
    name                 = var.vnet_name
    resource_group_name  = var.rg_name
    location             = var.location
    address_space        = var.address_space
    tags                 = var.tags
    
  lifecycle {
      ignore_changes = [
        tags["createdDate"]
      ]
    }

}


#Output
output "id" {
  value = azurerm_virtual_network.vnet.id
}

output "name" {
  value = azurerm_virtual_network.vnet.name
}

