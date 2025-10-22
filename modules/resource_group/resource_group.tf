terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.12.0"
    }
  }
  required_version = ">= 1.1.0"
}

variable "environment" {}

variable "tags" {}
variable "rg_name" {}
variable "location" {}

resource "azurerm_resource_group" "resource_group" {
    name     = var.rg_name
    location = var.location
    tags     = var.tags
  
  lifecycle {
    ignore_changes = [
      tags["createdDate"]
    ]
  }
}


#Output

output "name" {
  value = azurerm_resource_group.resource_group.name
}
