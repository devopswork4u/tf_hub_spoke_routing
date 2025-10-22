variable "environment" {}
variable "instance_number" {}
variable "primary_resource_group_name" {}
variable "secondary_resource_group_name" {}
variable "location" {}
variable "secondary_location" {}
variable "admin_user" {}
variable "login_password" {}
variable "sku_name" {
  default = "GP_Gen5"
}
variable "tags" {}

variable "subnet_id" {}

resource "azurerm_mssql_managed_instance" "primary" {
  name                         = "sqlmi-${var.location}-${environment}-${var.instance_number}"
  resource_group_name          = var.primary_resource_group_name
  location                     = var.location
  administrator_login          = var.admin_user
  administrator_login_password = var.login_password
  license_type                 = "BasePrice"
  subnet_id                    = lookup(var.subnet_id, each.value.name, null)
  sku_name                     = var.sku_name #"GP_Gen5"
  vcores                       = 4
  storage_size_in_gb           = 32
  tags                         = var.tags
}

resource "azurerm_mssql_managed_instance" "secondary" {
  name                         = "sqlmi-${var.secondary_location}-${environment}-${var.instance_number}"
  resource_group_name          = var.secondary_resource_group_name
  location                     = var.secondary_location
  administrator_login          = var.admin_user
  administrator_login_password = var.login_password
  license_type                 = "BasePrice"
  subnet_id                    = lookup(var.subnet_id, each.value.name, null)
  sku_name                     = var.sku_name #"GP_Gen5"
  vcores                       = 4
  storage_size_in_gb           = 32
  tags                         = var.tags
}

resource "azurerm_mssql_managed_instance_failover_group" "mifq" {
  name                        = "fg-eus-wus-${environment}-${var.instance_number}"
  location                    = azurerm_mssql_managed_instance.primary.location
  managed_instance_id         = azurerm_mssql_managed_instance.primary.id
  partner_managed_instance_id = azurerm_mssql_managed_instance.secondary.id

  read_write_endpoint_failover_policy {
    mode          = "Automatic"
    grace_minutes = 60
  }
}