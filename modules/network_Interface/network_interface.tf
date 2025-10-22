terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.12.0"
    }
  }
  required_version = ">= 1.1.0"
}


variable "nic_name"{}
variable "subnet_id" {}
variable "rg_name"{}
variable "location" {}
variable "public_ip_id" {
  type    = string
  default = null
}
variable "tags" {}

resource "azurerm_network_interface" "nic" {
    name                        = var.nic_name
    resource_group_name = var.rg_name
    location                    = var.location
    tags                        = var.tags
    
    ip_configuration {
        name = "ipconfic"
        private_ip_address_allocation= "Dynamic"
        subnet_id = var.subnet_id
        public_ip_address_id          = var.public_ip_id
    }

    lifecycle {
    ignore_changes = [
      tags["createdDate"]
    ]
  }

}

#Output
output "id" {
  value = azurerm_network_interface.nic.id
}