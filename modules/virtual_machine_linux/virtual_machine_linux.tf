terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.12.0"
    }
  }
  required_version = ">= 1.1.0"
}

variable "vm_size" {
  type = string
}

variable "admin_username" {
  type = string
}

variable "admin_password" {
  type = string
}

variable "rg_name"{}
variable "vm_name" {}
variable "location" {}

variable "nic_id"{}

variable "tags" {}

resource "azurerm_linux_virtual_machine" "vm" {
    name                  = var.vm_name
    resource_group_name   = var.rg_name
    location              = var.location
    size                  = var.vm_size
    admin_username        = var.admin_username
    admin_password        = var.admin_password
    network_interface_ids = var.nic_id
    disable_password_authentication = false

  os_disk {
    name                 = "osdisk-${var.vm_name}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      tags["createdDate"]
    ]
  }
}