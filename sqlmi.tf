
# resource "azurerm_mssql_managed_instance" "primary" {
#   name                         = "sqlmi-${var.location}-${var.environment}-${var.instance_number}"
#   resource_group_name          = module.resource_group.east_rg
#   location                     = var.location
#   administrator_login          = var.admin_user
#   administrator_login_password = var.login_password
#   license_type                 = "BasePrice"
#   subnet_id                    = module.subnets.east_snet
#   sku_name                     = var.sku_name #"GP_Gen5"
#   vcores                       = 4
#   storage_size_in_gb           = 32

# }

# resource "azurerm_mssql_managed_instance" "secondary" {
#   name                         = "sqlmi-${var.secondary_location}-${var.environment}-${var.instance_number}"
#   resource_group_name          = module.resource_group.west_rg
#   location                     = var.secondary_location
#   administrator_login          = var.admin_user
#   administrator_login_password = var.login_password
#   license_type                 = "BasePrice"
#   subnet_id                    = module.subnets.west_snet
#   sku_name                     = var.sku_name #"GP_Gen5"
#   vcores                       = 4
#   storage_size_in_gb           = 32
# }

# resource "azurerm_mssql_managed_instance_failover_group" "mifq" {
#   name                        = "fg-eus-wus-${var.environment}-${var.instance_number}"
#   location                    = azurerm_mssql_managed_instance.primary.location
#   managed_instance_id         = azurerm_mssql_managed_instance.primary.id
#   partner_managed_instance_id = azurerm_mssql_managed_instance.secondary.id

#   read_write_endpoint_failover_policy {
#     mode          = "Automatic"
#     grace_minutes = 60
#   }
# }